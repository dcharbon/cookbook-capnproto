include_recipe 'build-essential'
include_recipe 'apt'

package "libtool" do
  :install
end

package "python-software-properties" do
  :install
end

execute "Add ubuntu toolchain apt repo" do
  command "add-apt-repository ppa:ubuntu-toolchain-r/test && apt-get update"
end

package "gcc-4.8" do
  :install
end

package "g++-4.8" do
  :install
end

execute "Update gcc alternatives" do
  command "update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.6 40 --slave /usr/bin/g++ g++ /usr/bin/g++-4.6 && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.8"
end

version = node[:capnproto][:version]
download_url = node[:capnproto][:download_url] % { :version => version }
tar_gz = File.join(
  Chef::Config[:file_cache_path],
  "/",
  "capnproto-c++-#{version}.tar.gz")

unless File.exists?("/usr/local/lib/libcapnp.so")
  remote_file tar_gz do
    source download_url
  end

  execute "ungzip-capnproto" do
    cwd Chef::Config[:file_cache_path]
    command "tar xzf #{tar_gz}"
  end

  execute "make-install-capnproto" do
    cwd "#{Chef::Config[:file_cache_path]}/capnproto-c++-#{version}"
    #command "CXX=clang++ ./configure && make -j6 check && make install"
    #command "./configure && make -j6 check && make install"
    command "./configure && make install"
  end
end
