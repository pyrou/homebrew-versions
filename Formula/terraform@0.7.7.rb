require "language/go"

class TerraformAT077 < Formula
  desc "Tool to build, change, and version infrastructure"
  homepage "https://www.terraform.io/"
  url "https://github.com/hashicorp/terraform/archive/0.7.7.tar.gz"
  sha256 "ae20e9b1348c7e3b7fe95a05a05848b33492dad4828274c60026139280a139eb"
  head "https://github.com/hashicorp/terraform.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "a8339b96d926b1f289396711bee3bb9281fccdd2b0f19bd63625a17002e53e96" => :mojave
    sha256 "ef4d436a8fc18ae56eb83789d3febe066f18251b74442c08a818d61ed986d811" => :high_sierra
    sha256 "dc8f15ea8b13741ae3e24c1776860b4e34f0c7a483cb2b158c8076b13a742424" => :sierra
    sha256 "6abe186fd9010b52ce24a7b27fbfd71448752f968e93825eca111f9d4b1688f5" => :el_capitan
    sha256 "c12d2cb75fb0e2df174f32cc6472b37d060a86ee19e649b90e8e0e33a30a7ab6" => :yosemite
  end

  depends_on "go" => :build
  depends_on "gox" => :build

  conflicts_with "tfenv", :because => "tfenv symlinks terraform binaries"

  def install
    ENV["GOPATH"] = buildpath
    ENV.prepend_create_path "PATH", buildpath/"bin"

    dir = buildpath/"src/github.com/hashicorp/terraform"
    dir.install buildpath.children - [buildpath/".brew_home"]

    cd dir do
      # v0.6.12 - source contains tests which fail if these environment variables are set locally.
      ENV.delete "AWS_ACCESS_KEY"
      ENV.delete "AWS_SECRET_KEY"

      ENV["XC_OS"] = "darwin"
      ENV["XC_ARCH"] = "amd64"
      system "make", "tools", "test", "bin"

      bin.install "pkg/darwin_amd64/terraform"
      prefix.install_metafiles
    end
  end

  test do
    minimal = testpath/"minimal.tf"
    minimal.write <<~EOS
      variable "aws_region" {
        default = "us-west-2"
      }
      variable "aws_amis" {
        default = {
          eu-west-1 = "ami-b1cf19c6"
          us-east-1 = "ami-de7ab6b6"
          us-west-1 = "ami-3f75767a"
          us-west-2 = "ami-21f78e11"
        }
      }
      # Specify the provider and access details
      provider "aws" {
        access_key = "this_is_a_fake_access"
        secret_key = "this_is_a_fake_secret"
        region     = var.aws_region
      }
      resource "aws_instance" "web" {
        instance_type = "m1.small"
        ami           = var.aws_amis[var.aws_region]
        count         = 4
      }
    EOS
    system "#{bin}/terraform", "init"
    system "#{bin}/terraform", "graph"
  end
end
