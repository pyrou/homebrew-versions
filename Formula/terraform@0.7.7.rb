class TerraformAT077 < Formula 
  desc "Tool to build, change, and version infrastructure"
  homepage "https://www.terraform.io/"
  url "https://releases.hashicorp.com/terraform/0.7.7/terraform_0.7.7_darwin_amd64.zip"
  sha256 "eb6255c4c14c61458ea4598a0e3176695c296e9f1650ad56a24a1cb75d8fef35"

  def install
    bin.install "terraform"
    prefix.install_metafiles
    system "pip", "install", "boto" 
  end
end
