#!/bin/bash
set -eux

DIR=$(pwd)

rustup default beta
rustc --version

echo '#### Checkout rust and vendored deps'
if [ ! -d rust ]; then
  git clone https://github.com/rust-lang/rust || true
  cd rust
  git checkout f19ccc2e8dab09e542d4c5a3ec14c7d5bce8d50e
  git submodule update --init --recursive
  cd $DIR
fi

COMPILER_BUILTINS=compiler-builtins-0.1.73
if [ ! -d $COMPILER_BUILTINS ]; then
  wget -qO- https://github.com/rust-lang/compiler-builtins/archive/refs/tags/0.1.73.tar.gz | tar xzf -
fi

LIBC=libc-0.2.126
if [ ! -d $LIBC ]; then
  wget -qO- https://github.com/rust-lang/libc/archive/refs/tags/0.2.126.tar.gz | tar xzf -
fi

CFG_IF=cfg-if-0.1.10
if [ ! -d $CFG_IF ]; then
  wget -qO- https://github.com/alexcrichton/cfg-if/archive/refs/tags/0.1.10.tar.gz | tar xzf -
fi

RUSTC_DEMANGLE=rustc-demangle-0.1.21
if [ ! -d $RUSTC_DEMANGLE ]; then
  wget -qO- https://github.com/rust-lang/rustc-demangle/archive/refs/tags/0.1.21.tar.gz | tar xzf -
fi

HASHBROWN=hashbrown-0.12.1
if [ ! -d $HASHBROWN ]; then
  wget -qO- https://github.com/rust-lang/hashbrown/archive/refs/tags/v0.12.1.tar.gz | tar xzf -
fi

echo '#### Build stdlibs'
if [ ! -d outdir ]; then
  mkdir outdir
fi

if [ ! -f outdir/libcore-1934803528.rlib ]; then
  RUSTC_BOOTSTRAP=1 rustc rust/library/core/src/lib.rs '--crate-name=core' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-1934803528' '--codegen=extra-filename=-1934803528' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--emit=link' '--target=x86_64-unknown-linux-gnu' '--cap-lints=allow' -Zunstable-options '-Csymbol-mangling-version=legacy' '--edition=2021' '--cfg=bootstrap' '-Ccodegen-units=1'
fi

if [ ! -f outdir/libcompiler_builtins-1071363765.rlib ]; then
  RUSTC_BOOTSTRAP=1 rustc $COMPILER_BUILTINS/src/lib.rs '--crate-name=compiler_builtins' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-1071363765' '--codegen=extra-filename=-1071363765' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=.' '--emit=link' '--color=always' '--target=x86_64-unknown-linux-gnu' --cfg 'feature="compiler-builtins"' '--cap-lints=allow' '-Cmetadata=rustc_internal' -Zforce-unstable-if-unmarked '--cfg=feature="mem-unaligned"' '--cfg=feature="unstable"' '--extern=core=outdir/libcore-1934803528.rlib' '-Ldependency=outdir' '--cfg=bootstrap' '-Ccodegen-units=1'
fi

if [ ! -f outdir/liblibc-241958726.rlib ]; then
  RUSTC_BOOTSTRAP=1 rustc $LIBC/src/lib.rs '--crate-name=libc' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-241958726' '--codegen=extra-filename=-241958726' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=.' '--emit=link' '--color=always' '--target=x86_64-unknown-linux-gnu' --cfg 'feature="rustc-dep-of-std"' --cfg 'feature="align"' '--cap-lints=allow' '-Cmetadata=rustc_internal' -Zforce-unstable-if-unmarked '--cfg=libc_align' '--extern=rustc_std_workspace_core=outdir/libcore-1934803528.rlib' '-Ldependency=blaze-out/k8-opt/bin/third_party/rust_toolchain/library' '--cfg=bootstrap' '-Ccodegen-units=1'
fi

if [ ! -f outdir/libcfg_if-2310294875.rlib ]; then
  RUSTC_BOOTSTRAP=1 rustc $CFG_IF/src/lib.rs '--crate-name=cfg_if' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-2310294875' '--codegen=extra-filename=-2310294875' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=.' '--emit=link' '--color=always' '--target=x86_64-unknown-linux-gnu' --cfg 'feature="compiler-builtins"' '--cap-lints=allow' '-Cmetadata=rustc_internal' -Zforce-unstable-if-unmarked '--edition=2018' '--extern=compiler_builtins=outdir/libcompiler_builtins-1071363765.rlib' '--extern=core=outdir/libcore-1934803528.rlib' '-Ldependency=outdir' '--cfg=bootstrap' '-Ccodegen-units=1'
fi

if [ ! -f outdir/librustc_demangle-3774576121.rlib ]; then
  RUSTC_BOOTSTRAP=1 rustc $RUSTC_DEMANGLE/src/lib.rs '--crate-name=rustc_demangle' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-3774576121' '--codegen=extra-filename=-3774576121' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=.' '--emit=link' '--color=always' '--target=x86_64-unknown-linux-gnu' '--cap-lints=allow' '-Cmetadata=rustc_internal' -Zforce-unstable-if-unmarked '--extern=compiler_builtins=outdir/libcompiler_builtins-1071363765.rlib' '--extern=core=outdir/libcore-1934803528.rlib' '--cfg=bootstrap' '-Ccodegen-units=1'
fi

if [ ! -f  outdir/liballoc-384047890.rlib ]; then
  RUSTC_BOOTSTRAP=1 rustc rust/library/alloc/src/lib.rs '--crate-name=alloc' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-384047890' '--codegen=extra-filename=-384047890' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=.' '--emit=link' '--color=always' '--target=x86_64-unknown-linux-gnu' '--cap-lints=allow' '--edition=2021' '--extern=compiler_builtins=outdir/libcompiler_builtins-1071363765.rlib' '--extern=core=outdir/libcore-1934803528.rlib' '-Ldependency=outdir' '--cfg=bootstrap' '-Ccodegen-units=1'
fi

if [ ! -f outdir/libunwind-380821176.rlib ]; then
  RUSTC_BOOTSTRAP=1 rustc rust/library/unwind/src/lib.rs '--crate-name=unwind' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-380821176' '--codegen=extra-filename=-380821176' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=.' '--emit=link' '--color=always' '--target=x86_64-unknown-linux-gnu' --cfg 'feature="llvm-libunwind"' -Zforce-unstable-if-unmarked '--edition=2021' '--extern=cfg_if=outdir/libcfg_if-2310294875.rlib' '--extern=compiler_builtins=outdir/libcompiler_builtins-1071363765.rlib' '--extern=core=outdir/libcore-1934803528.rlib' '--extern=libc=outdir/liblibc-241958726.rlib' '-Ldependency=outdir' '--cfg=bootstrap' '-Ccodegen-units=1'
fi

if [ ! -f outdir/libpanic_unwind-1458542728.rlib ]; then
  RUSTC_BOOTSTRAP=1 rustc rust/library/panic_unwind/src/lib.rs '--crate-name=panic_unwind' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-1458542728' '--codegen=extra-filename=-1458542728' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=.' '--emit=link' '--color=always' '--target=x86_64-unknown-linux-gnu' --cfg 'feature="rustc_private"' '--cap-lints=allow' -Zforce-unstable-if-unmarked '--edition=2021' '--extern=alloc=outdir/liballoc-384047890.rlib' '--extern=cfg_if=outdir/libcfg_if-2310294875.rlib' '--extern=compiler_builtins=outdir/libcompiler_builtins-1071363765.rlib' '--extern=core=outdir/libcore-1934803528.rlib' '--extern=libc=outdir/liblibc-241958726.rlib' '--extern=unwind=outdir/libunwind-380821176.rlib' '--cfg=bootstrap' '-Ccodegen-units=1'
fi

if [ ! -f outdir/libstd_detect-2775444999.rlib ]; then
  RUSTC_BOOTSTRAP=1 rustc rust/library/stdarch/crates/std_detect/src/lib.rs '--crate-name=std_detect' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-2775444999' '--codegen=extra-filename=-2775444999' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=.' '--emit=link' '--color=always' '--target=x86_64-unknown-linux-gnu' --cfg 'feature="rustc-dep-of-std"' --cfg 'feature="core"' --cfg 'feature="compiler_builtins"' --cfg 'feature="alloc"' '--cap-lints=allow' '-Cmetadata=rustc_internal' -Zforce-unstable-if-unmarked '--edition=2021' '--extern=cfg_if=outdir/libcfg_if-2310294875.rlib' '--extern=compiler_builtins=outdir/libcompiler_builtins-1071363765.rlib' '--extern=core=outdir/libcore-1934803528.rlib' '--extern=libc=outdir/liblibc-241958726.rlib' '-Ldependency=outdir' '--cfg=bootstrap' '-Ccodegen-units=1'
fi

if [ ! -f outdir/libpanic_abort-1847932942.rlib ]; then
  RUSTC_BOOTSTRAP=1 rustc rust/library/panic_abort/src/lib.rs '--crate-name=panic_abort' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-1847932942' '--codegen=extra-filename=-1847932942' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=.' '--emit=link' '--color=always' '--target=x86_64-unknown-linux-gnu' --cfg 'feature="rustc_private"' '--cap-lints=allow' -Zforce-unstable-if-unmarked '--edition=2021' '--extern=alloc=outdir/liballoc-384047890.rlib' '--extern=cfg_if=outdir/libcfg_if-2310294875.rlib' '--extern=compiler_builtins=outdir/libcompiler_builtins-1071363765.rlib' '--extern=core=outdir/libcore-1934803528.rlib' '--extern=libc=outdir/liblibc-241958726.rlib' '-Ldependency=outdir' '--cfg=bootstrap' '-Ccodegen-units=1'
fi

if [ ! -f outdir/libhashbrown-2545358579.rlib ]; then
  RUSTC_BOOTSTRAP=1 rustc $HASHBROWN/src/lib.rs '--crate-name=hashbrown' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-2545358579' '--codegen=extra-filename=-2545358579' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=.' '--emit=dep-info,link' '--color=always' '--target=x86_64-unknown-linux-gnu' --cfg 'feature="alloc"' --cfg 'feature="compiler_builtins"' --cfg 'feature="core"' --cfg 'feature="nightly"' --cfg 'feature="rustc-dep-of-std"' --cfg 'feature="rustc-internal-api"' '--cap-lints=allow' '-Cmetadata=rustc_internal' -Zforce-unstable-if-unmarked '--edition=2018' '--extern=alloc=outdir/liballoc-384047890.rlib' '--extern=compiler_builtins=outdir/libcompiler_builtins-1071363765.rlib' '--extern=core=outdir/libcore-1934803528.rlib' '-Ldependency=outdir' '--cfg=bootstrap' '-Ccodegen-units=1'
fi

if [ ! -f outdir/libstd-649841298.rlib ]; then
  RUSTC_BOOTSTRAP=1 STD_ENV_ARCH=x86_64 rustc rust/library/std/src/lib.rs '--crate-name=std' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-649841298' '--codegen=extra-filename=-649841298' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=.' '--emit=dep-info,link' '--color=always' '--target=x86_64-unknown-linux-gnu' --cfg 'feature="panic-unwind"' --cfg 'feature="panic_unwind"' '--cap-lints=allow' '--cfg=backtrace_in_libstd' -Zforce-unstable-if-unmarked -Zunstable-options '-Csymbol-mangling-version=legacy' '--edition=2021' '--extern=alloc=outdir/liballoc-384047890.rlib' '--extern=cfg_if=outdir/libcfg_if-2310294875.rlib' '--extern=compiler_builtins=outdir/libcompiler_builtins-1071363765.rlib' '--extern=core=outdir/libcore-1934803528.rlib' '--extern=hashbrown=outdir/libhashbrown-2545358579.rlib' '--extern=libc=outdir/liblibc-241958726.rlib' '--extern=panic_abort=outdir/libpanic_abort-1847932942.rlib' '--extern=panic_unwind=outdir/libpanic_unwind-1458542728.rlib' '--extern=rustc_demangle=outdir/librustc_demangle-3774576121.rlib' '--extern=std_detect=outdir/libstd_detect-2775444999.rlib' '--extern=unwind=outdir/libunwind-380821176.rlib' '-Ldependency=outdir' '--cfg=bootstrap' '-Ccodegen-units=1'
fi

if [ ! -f outdir/libproc_macro-1655557384.rlib  ]; then
  RUSTC_BOOTSTRAP=1 rustc rust/library/proc_macro/src/lib.rs '--crate-name=proc_macro' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-1655557384' '--codegen=extra-filename=-1655557384' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=.' '--emit=dep-info,link' '--color=always' '--target=x86_64-unknown-linux-gnu' '--cap-lints=allow' -Zunstable-options '-Csymbol-mangling-version=legacy' '--edition=2021' '--extern=std=outdir/libstd-649841298.rlib' '-Ldependency=outdir' '--cfg=bootstrap' '-Ccodegen-units=1'
fi

ls outdir

echo '#### Set up local sysroot'

if [ ! -d sysroot ]; then
  BETA_SYSROOT="$(rustc --print=sysroot)"
  rsync -a --delete $BETA_SYSROOT sysroot
  rm sysroot/beta-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-unknown-linux-gnu/lib/*
  cp outdir/*.rlib sysroot/beta-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-unknown-linux-gnu/lib
  # Create an empty libunwind.a to satisfy the linker commandline created by rustc
  # while building proc_macro-s.
  ar cr sysroot/beta-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-unknown-linux-gnu/lib/libunwind.a
fi

RUSTC=sysroot/beta-x86_64-unknown-linux-gnu/bin/rustc

$RUSTC --version
$RUSTC --print=sysroot

echo '#### Build the reproducer reproducer'

RUSTC_BOOTSTRAP=1 $RUSTC serde_derive/lib.rs '--crate-name=serde_derive' '--crate-type=proc-macro' '--error-format=human' '--codegen=metadata=-533952090' '--codegen=extra-filename=-533952090' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=.' '--emit=dep-info,link' '--color=always' '--target=x86_64-unknown-linux-gnu' '--cap-lints=allow' '--cfg=ptr_addr_of' '--cfg=underscore_consts' '--cfg=bootstrap' '-Ccodegen-units=1' '-Cmetadata=rustc_internal_rlibs' -Zforce-unstable-if-unmarked 
RUSTC_BOOTSTRAP=1 $RUSTC serde/lib.rs '--crate-name=serde' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-2557206172' '--codegen=extra-filename=-2557206172' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=.' '--emit=dep-info,link' '--color=always' '--target=x86_64-unknown-linux-gnu' --cfg 'feature="derive"' --cfg 'feature="rc"' --cfg 'feature="serde_derive"' --cfg 'feature="std"' '--cap-lints=allow' '--extern=serde_derive=outdir/libserde_derive-533952090.so' '-Ldependency=outdir' '--cfg=bootstrap' '-Ccodegen-units=1' '-Cmetadata=rustc_internal_rlibs' -Zforce-unstable-if-unmarked
RUSTC_BOOTSTRAP=1 $RUSTC gsgdt/lib.rs '--crate-name=gsgdt' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-813700370' '--codegen=extra-filename=-813700370' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=.' '--emit=dep-info,link' '--color=always' '--target=x86_64-unknown-linux-gnu' '--cap-lints=allow' '-Csymbol-mangling-version=v0' '--cfg=bootstrap' -Zunstable-options '--edition=2018' '--extern=serde=outdir/libserde-2557206172.rlib' '-Ldependency=outdir' '--cfg=bootstrap' '-Ccodegen-units=1' '-Cmetadata=rustc_internal_rlibs' -Zforce-unstable-if-unmarked
