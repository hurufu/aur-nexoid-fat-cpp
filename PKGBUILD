# Maintainer: Aleksy Grabowski <hurufu@gmail.com>

pkgname=nexoid-fat-cpp-git
pkgver=0.2.0
pkgrel=1
pkgdesc='NEXO Financial Application for Terminals (FAT) implemented in C++'
arch=(i686 x86_64)
url='http://nexoid.invalid' # Website doesn't exist yet
license=(AGPL)
depends=(
    nngpp-git
    libsocket
)
makedepends=(
    git
    sed
    make
    gcc
    asn1c
    lsof
    drakon-editor
)
provides=(nexoid-fat)
source=(
    "git+ssh://git@github.com:/hurufu/nexoid-fat-cpp.git"
    "git+ssh://git@github.com:/hurufu/nexoid-ed.git"
    "git+ssh://git@github.com:/hurufu/nexoid-protocol-collection.git"
)
sha256sums=(
    SKIP
    SKIP
    SKIP
)

pkgver() {
    git -C "$srcdir/nexoid-fat-cpp" describe | awk -F - '{ print substr($1,2) ( $2 ? ".r"$2"."$3 : "") }'
}

build() {
    cd "$srcdir/nexoid-fat-cpp"
    git submodule init
    git config submodule.nexoid-ed.url "$srcdir/nexoid-ed"
    git config submodule.nexoid-protocol-collection.url "$srcdir/nexoid-protocol-collection"
    git submodule update
    export DRAKON_PATH=/usr/share/drakon-editor
    make all
}

package() {
    cd "$srcdir/nexoid-fat-cpp"
    make DESTDIR="$pkgdir" PREFIX=/usr install
}
