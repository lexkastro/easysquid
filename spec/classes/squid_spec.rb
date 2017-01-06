# spec/classes/easysquid_spec.rb

require 'spec_helper'

describe 'easysquid' do

  # Test if RedHat release is wrong
  context "With wrong redhat 5.x" do
    let(:facts) {
      {
        :osfamily => 'RedHat',
        :operatingsystemmajrelease => '5',
      } 
    }
    it { is_expected.to raise_error(Puppet::Error) }
  end

  # Test if RedHat release is wrong
  context "With wrong debiant 8.x" do
    let(:facts) {
      {
        :osfamily => 'Debian',
        :operatingsystemmajrelease => '8',
      } 
    }
    it { is_expected.to raise_error(Puppet::Error) }
  end

  # Test if Debian release is wrong
  context "With wrong debiant 6.x" do
    let(:facts) {
      {
        :osfamily => 'Debian',
        :operatingsystemmajrelease => '6',
      }
    }
    it { is_expected.to raise_error(Puppet::Error) }
  end

  # Test if init manifest load all classes
  context "With init class" do
    let(:facts) {
      {
        :osfamily => 'RedHat',
        :operatingsystemmajrelease => '6',
      }
    }

    it { 
      should contain_class('easysquid')
      should contain_class('easysquid::install')
      should contain_class('easysquid::config')
      should contain_class('easysquid::service')
      should contain_class('easysquid::fragments')
      should contain_class('easysquid::params')
    }
  end

  # Test default resources for RedHat
  context "With RedHat System'" do
    let(:facts) {
      {
        :osfamily => 'RedHat',
        :operatingsystemmajrelease => '7',
      }
    }

    it {
      should contain_package('squid')
      should contain_service('squid')
      should contain_user('squid')
      should contain_group('squid')
      should contain_file('/etc/squid/cachemgr.conf')
      should contain_file('/etc/squid/errorpage.css')
      should contain_file('/etc/squid/mime.conf')
      should contain_file('/etc/squid')
      should contain_concat('/etc/squid/squid.conf')
      should contain_concat__fragment('access-block-begin')
      should contain_concat__fragment('access-block-end')
      should contain_concat__fragment('acl-block-begin')
      should contain_concat__fragment('refresh-pattern-block')
      should contain_concat__fragment('squid-main-configuration-content')
    }
  end

  # Test default resources for Debian
  context "With Debian System" do
    let(:facts) {
      {
        :osfamily => 'Debian',
        :operatingsystemmajrelease => '7',
      }
    }

    it {
      should contain_package('squid3')
      should contain_service('squid3')
      should contain_user('proxy')
      should contain_group('proxy')
      should contain_file('/etc/squid3/cachemgr.conf')
      should contain_file('/etc/squid3/errorpage.css')
      should contain_file('/etc/squid3/mime.conf')
      should contain_file('/etc/squid3')
      should contain_concat('/etc/squid3/squid.conf')
      should contain_concat__fragment('access-block-begin')
      should contain_concat__fragment('access-block-end')
      should contain_concat__fragment('acl-block-begin')
      should contain_concat__fragment('refresh-pattern-block')
      should contain_concat__fragment('squid-main-configuration-content')
    }
  end

  # Test custom configuration
  context "With custom config" do
    let(:facts) {
      {
        :osfamily => 'RedHat',
        :operatingsystemmajrelease => '7',
      }
    }

    let(:custom_config) { 'SQUID_SPEC' }

    it {
      should contain_user('squid')
      should contain_group('squid')
      should contain_concat('/etc/squid/squid.conf')
    }
  end
end
