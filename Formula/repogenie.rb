require "net/http"
require "json"
require "tempfile"

# GitHubPrivateRepositoryReleaseDownloadStrategy
#
# Downloads a tarball from a PRIVATE GitHub repository using a Personal Access
# Token. Users export HOMEBREW_GITHUB_API_TOKEN in their shell; Homebrew picks
# it up automatically and uses it to authenticate the download.
#
# Pattern documented in the Homebrew "Interesting Taps and Formulae" wiki and
# used by multiple private-tap formulae in production.

class GitHubPrivateRepositoryReleaseDownloadStrategy < CurlDownloadStrategy
  require "utils/github"

  def initialize(url, name, version, **meta)
    super
    parse_url_pattern
    set_github_token
  end

  def parse_url_pattern
    unless match = url.match(%r{https://github.com/([^/]+)/([^/]+)/archive/refs/tags/([^/]+)\.tar\.gz})
      raise CurlDownloadStrategyError, "Invalid url pattern for GitHub private release."
    end
    _, @owner, @repo, @tag = *match
  end

  def set_github_token
    @github_token = ENV["HOMEBREW_GITHUB_API_TOKEN"]
    unless @github_token
      raise CurlDownloadStrategyError, <<~EOS
        HOMEBREW_GITHUB_API_TOKEN is required to install repogenie from its private repo.

        1. Create a classic PAT at https://github.com/settings/tokens
           with scope: repo
        2. Export it in your shell:
             export HOMEBREW_GITHUB_API_TOKEN=ghp_xxxxxxxxxxxx
        3. Re-run: brew install dwelitics/repogenie/repogenie
      EOS
    end
  end

  def _fetch(url:, resolved_url:, timeout:)
    curl_download download_url, to: temporary_path
  end

  def download_url
    # GitHub API tarball endpoint with token auth — returns the tarball for the tag.
    "https://#{@github_token}@api.github.com/repos/#{@owner}/#{@repo}/tarball/#{@tag}"
  end
end

class Repogenie < Formula
  desc "Per-repo Claude Code operating-system installer"
  homepage "https://github.com/dwelitics/repogenie"
  url "https://github.com/dwelitics/repogenie/archive/refs/tags/v4.1.0.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "8d814548c0a34586b4d2d9cf9d547a548e37443ad149682b10295d1d533b038a"
  license "MIT"
  version "4.1.0"

  depends_on "bash"

  def install
    # Install the CLI entry point
    bin.install "bin/repogenie"

    # Install shared lib into libexec/repogenie/lib/
    # (bin/repogenie walks ../libexec/repogenie/lib first when running from Homebrew)
    (libexec/"repogenie").mkpath
    (libexec/"repogenie").install "lib"

    # Install assets (commands, agents, templates, VERSION, CHANGELOG)
    # pkgshare is <prefix>/share/repogenie — matches what bin/repogenie expects
    pkgshare.install "commands"
    pkgshare.install "agents"
    pkgshare.install "templates"
    pkgshare.install "copilot-templates" if Dir.exist?("copilot-templates")
    pkgshare.install "VERSION"
    pkgshare.install "CHANGELOG.md" if File.exist?("CHANGELOG.md")
  end

  test do
    assert_match "repogenie", shell_output("#{bin}/repogenie --version")
    assert_match "per-repo", shell_output("#{bin}/repogenie --help")
  end
end
