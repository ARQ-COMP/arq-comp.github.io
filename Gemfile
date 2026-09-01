source "https://rubygems.org"

# This Gemfile exists so the site can be built and previewed locally.
#
# It deliberately does NOT use the `github-pages` metagem. That gem pins a
# 2013-era dependency tree whose native extensions no longer compile on current
# Ruby -- `bundle install` would fail outright. GitHub Pages ignores this file
# anyway: the deployed site is built by Pages' own pinned environment, which is
# still Jekyll 3.10.
#
# The consequence is that a local build is close to production but not
# identical. Anything Liquid-, SCSS- or content-level will behave the same;
# Jekyll 3-vs-4 edge cases will not be caught here.
gem "jekyll", "~> 4.4"

group :jekyll_plugins do
  # Both are also declared in _config.yml, which is what GitHub Pages reads --
  # this group is what makes them load locally.
  gem "jekyll-remote-theme", "~> 0.4"
  gem "jekyll-seo-tag", "~> 2.8"
end

# Dropped from Ruby's standard library in 3.0; `jekyll serve` needs it.
gem "webrick", "~> 1.9"
