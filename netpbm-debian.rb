# Since the "main" netpbm version makes me crazy,
# let's package up the Debian fork.

class NetpbmDebian < Formula
  desc "Debian fork of NetPBM"
  homepage "https://packages.debian.org/source/wheezy/netpbm-free"
  url "git://anonscm.debian.org/collab-maint/netpbm.git", :tag => "debian/10.0-15.1", :shallow => false
  version "10.0-15.1"

  option :universal

  # Just so I don't have to worry about not having GNU "install"...
  depends_on "coreutils" => :build

  depends_on "libtiff" => :recommended
  # Doesn't work with modern jpeg or libpng, so...
  depends_on "jpeg6b" => :recommended
  depends_on "libpng12" => :recommended

  conflicts_with "netpbm", :because => "fork of the same software"

  def install
    ENV.universal_binary if build.universal?
    jpeg = Formula["jpeg6b"].opt_prefix
    libtiff = Formula["libtiff"].opt_prefix
    libpng = Formula["libpng12"].opt_prefix

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
      if build.with? "jpeg6b"
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
    system "make", "PREFIX=#{prefix}", "INSTALLMAN=#{prefix}/share/man"
    system "make", "PREFIX=#{prefix}", "INSTALLMAN=#{prefix}/share/man", "install"
  end

  test do
    system "true"
  end
end
