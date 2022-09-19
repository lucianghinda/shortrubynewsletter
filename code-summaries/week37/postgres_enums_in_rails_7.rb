# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  gem "rails", github: "rails/rails", branch: "main"
  gem "pg"
end

require "active_record"
require "minitest/autorun"
require "logger"

# This connection will do for database-independent bug reports.
# You need to create a database before running this

ActiveRecord::Base.establish_connection(adapter: "postgresql", database: "postgres_enums_example")
ActiveRecord::Base.logger = Logger.new(STDOUT)


def migration_1_up
  ActiveRecord::Schema.define do
    create_enum :user_status, ["pending", "active", "archived"]
    create_table :users, force: true do |t|
      t.enum :status, enum_type: "user_status", default: "pending", null: false
    end
  end
end

def migration_2_up
  ActiveRecord::Schema.define do
    disable_ddl_transaction
    execute <<-SQL
      ALTER TYPE user_status ADD VALUE IF NOT EXISTS 'disabled' AFTER 'active';
    SQL
  end
end

# How to rename a value
def migration_3_up
  ActiveRecord::Schema.define do
    disable_ddl_transaction
    execute <<-SQL
      ALTER TYPE user_status RENAME VALUE 'pending' TO 'waiting';
    SQL

    change_column_default :users, :status, from: 'pending', to: 'waiting'
  end
end

def migration_3_down
  ActiveRecord::Schema.define do
    disable_ddl_transaction
    execute <<-SQL
      ALTER TYPE user_status RENAME VALUE 'waiting' TO 'pending';
    SQL
  end
end

def migration_4_up
  ActiveRecord::Schema.define do
    User.status_waiting.update_all(status: 'active')

    # change default to nil
    change_column_default :users, :status, nil

    execute <<-SQL
      --- Rename the old enum
      ALTER TYPE user_status RENAME TO user_status_old;

      --- Create the new enum as you will like it to be
      CREATE TYPE user_status AS ENUM('pending', 'active', 'archived');

      --- Alter the table to update it to use the new enum
      ALTER TABLE users ALTER COLUMN status TYPE user_status USING users::text::user_status;

      --- Drop the old status
      DROP TYPE user_status_old;
    SQL

    change_column_default :users, :status, 'pending'
  end
end

def migration_down
  ActiveRecord::Schema.define do
    drop_table :users

    execute <<-SQL
      DROP TYPE user_status;
    SQL
  end
end

class User < ActiveRecord::Base
  enum status: {
    pending: 'pending',
    active: 'active',
    archived: 'archived',
    disabled: 'disabled',
    waiting: 'waiting'
  }, _prefix: true
end

class TestUser < Minitest::Test
  def setup
    migration_1_up
    migration_2_up
  end

  def test_default_status_is_pending
    user = User.create!.reload
    assert user.status_pending?
  end

  def test_querying_records
    user = User.create!.reload
    assert_equal 1, User.status_pending.count
    assert_equal 0, User.status_active.count
  end

  def teardown
    migration_down
  end
end


class TestUserWithStatusRenamed < Minitest::Test
  def setup
    migration_1_up
    migration_2_up
    migration_3_up
  end

  def test_status_renamed
    result = ActiveRecord::Base.connection.execute <<-SQL
      SELECT UNNEST(enum_range(null::user_status)) AS user_status;
    SQL
    status_values = result.to_a.map(&:values).flatten

    refute_includes status_values, "pending"
    assert_includes status_values, "waiting"
  end

  def test_renamed_status_does_not_work
    user = User.create!.reload

    assert_raises(ActiveRecord::StatementInvalid) do
      assert_equal 1, User.status_pending.count
    end
  end

  def test_default_status_is_waiting
    user = User.create!.reload
    assert user.status_waiting?
  end

  def teardown
    migration_down
  end
end

class TestRemoveAStatus < Minitest::Test
  def setup
    migration_1_up
    migration_2_up
    migration_3_up
    migration_4_up
  end

  def test_status_removed
    result = ActiveRecord::Base.connection.execute <<-SQL
      SELECT UNNEST(enum_range(null::user_status)) AS user_status;
    SQL
    status_values = result.to_a.map(&:values).flatten

    assert_includes status_values, "pending"
    refute_includes status_values, "waiting"
  end

  def teardown
    migration_down
  end
end