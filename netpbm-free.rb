# Since the "main" netpbm version makes me crazy,
# let's package up the Debian fork.

class NetpbmFree < Formula
  desc "Debian fork of NetPBM"
  homepage "http://netpbm.alioth.debian.org/outside-debian.html"

  url "http://http.debian.net/debian/pool/main/n/netpbm-free/netpbm-free_10.0.orig.tar.gz"
  sha256 "ea3a653f3e5a32e09cea903c5861138f6a597670dff79e2b54e902f140cff2f3"

  # Debian distributes the source as a tarball and a patch to begin with.
  # This isn't a homebrew-specific patch, it's the patch to sync with
  # the Debian version "10.0-15.3".
  patch do
    url "http://http.debian.net/debian/pool/main/n/netpbm-free/netpbm-free_10.0-15.3.diff.gz"
    sha256 "42f9f2f98951f830bc738605fa4c698538c15aed1a0229162bdcf2c6cdf87915"
  end
  version "10.0-15.3"
  revision 4

  option :universal

  # Just so I don't have to worry about not having GNU "install"...
  depends_on "coreutils" => :build

  depends_on "libtiff" => :recommended
  # Doesn't work with modern jpeg or libpng, so...
  depends_on "jpeg@6" => :recommended
  #depends_on "jpeg6b-keg" => :recommended
  #depends_on "homebrew/versions/libpng12" => :recommended
  depends_on "libpng@12" => :recommended

  conflicts_with "netpbm", :because => "fork of the same software"

  def install
    ENV.universal_binary if build.universal?
    #jpeg = Formula["jpeg6b"].prefix
    jpeg = Formula["jpeg@6"].prefix
    libtiff = Formula["libtiff"].prefix
    libpng = Formula["libpng@12"].prefix

    cp "Makefile.config.in", "Makefile.config"

    inreplace "Makefile.config" do |s|
      s.change_make_var! "INSTALL", "ginstall -D"
      s.change_make_var! "CFLAGS_SHLIB", "-fno-common"
      s.change_make_var! "NETPBMLIBTYPE", "dylib"
      s.change_make_var! "NETPBMLIBSUFFIX", "dylib"
      s.change_make_var! "LDSHLIB", "--shared -o $(SONAME)"
      # The "fiasco" stuff didn't build correctly, so...
      s.change_make_var! "BUILD_FIASCO", "N"
      if build.with? "libtiff"
        s.change_make_var! "TIFFLIB_DIR", "#{libtiff}/lib"
        s.change_make_var! "TIFFHDR_DIR", "#{libtiff}/include"
        s.change_make_var! "TIFFLIB_LDFLAGS", "-lz"
      else
        s.change_make_var! "TIFFLIB_DIR", "NONE"
	s.change_make_var! "TIFFHDR_DIR", "NONE"
      end
      if build.with? "jpeg6b-keg"
        s.change_make_var! "JPEGLIB_DIR", "#{jpeg}/lib"
        s.change_make_var! "JPEGHDR_DIR", "#{jpeg}/include"
      else
        s.change_make_var! "JPEGLIB_DIR", "NONE"
	s.change_make_var! "JPEGHDR_DIR", "NONE"
      end
      if build.with? "libpng12"
        s.change_make_var! "PNGLIB_DIR", "#{libpng}/lib"
        s.change_make_var! "PNGHDR_DIR", "#{libpng}/include"
      else
        s.change_make_var! "PNGLIB_DIR", "NONE"
	s.change_make_var! "PNGHDR_DIR", "NONE"
      end
    end

    ENV.deparallelize
    system "make", "PREFIX=#{prefix}", "INSTALLMAN=#{man}"
    system "make", "PREFIX=#{prefix}", "INSTALLMAN=#{man}", "install"
  end

  test do
    system "true"
  end
end
