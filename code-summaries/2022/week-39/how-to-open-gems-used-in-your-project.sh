# Code summary for https://twitter.com/robbyrussell/status/1575164771389014016
#   including replies and I also added some of my own ideas

# 1️⃣ If you want to open an installed gem

gem open actionview -e code

# ▶️ or if you have set in your terminal $EDITOR or $VISUAL
gem open actionview

# ▶️ If you are inside a project that used Gemfile and has Gemfile.lock
bundle open actionview # to open the specific gem version from that project

# 2️⃣ If you did changes and want to reset

gem pristine actionview # to restore the gem to its cached version

bundle pristine # to restore the bundled gems to their cached version

bundle install --redownload # will redownload all bundled gems

# 👉 follow @shortrubynews and @lucianghinda for more content like this
