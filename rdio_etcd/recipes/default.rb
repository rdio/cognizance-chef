#
# Cookbook Name:: rdio_etcd
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'etcd::default'
include_recipe 'etcd::cluster'
