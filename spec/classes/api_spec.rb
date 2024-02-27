# frozen_string_literal: true

require 'spec_helper'

describe 'aptly::api' do
  context 'Using Systemd' do
    let(:facts) do
      {
        operatingsystem: 'Debian',
        operatingsystemrelease: '8.7',
        os: {
          architecture: 'amd64',
          distro: {
            codename: 'stretch',
            description: 'Debian GNU/Linux 9.4 (stretch)',
            id: 'Debian',
            release: {
              full: '9.4',
              major: '9',
              minor: '4'
            }
          },
          family: 'Debian',
          hardware: 'x86_64',
          name: 'Debian',
          release: {
            full: '9.4',
            major: '9',
            minor: '4'
          },
          selinux: {
            enabled: false
          }
        }
      }
    end

    context 'param defaults' do
      let(:params) { {} }

      it do
        is_expected.to contain_file('aptly-systemd')
          .with_path('/etc/systemd/system/aptly-api.service')
          .without_content(%r{^\s*author })
          .with_content(%r{^User=root$})
          .with_content(%r{^Group=root$})
          .with_content(%r{^ExecStart=\/usr\/bin\/aptly api serve -listen=:8080$})
          .that_notifies('Service[aptly-api]')
      end
      it do
        is_expected.to contain_service('aptly-api')
          .with_ensure('running')
          .with_enable(true)
      end
    end

    describe 'ensure' do
      context 'present (default)' do
        let(:params) { {} }

        it { is_expected.to contain_service('aptly-api').with_ensure('running') }
      end

      context 'stopped' do
        let(:params) do
          {
            ensure: 'stopped'
          }
        end

        it { is_expected.to contain_service('aptly-api').with_ensure('stopped') }
      end
    end

    describe 'user' do
      context 'custom' do
        let(:params) do
          {
            user: 'yolo'
          }
        end

        it { is_expected.to contain_file('aptly-systemd').with_content(%r{^User=yolo$}) }
      end
    end

    describe 'group' do
      context 'custom' do
        let(:params) do
          {
            group: 'yolo'
          }
        end

        it { is_expected.to contain_file('aptly-systemd').with_content(%r{^Group=yolo$}) }
      end
    end

    describe 'listen' do
      context 'custom' do
        let(:params) do
          {
            listen: '127.0.0.1:9090'
          }
        end

        it { is_expected.to contain_file('aptly-systemd').with_content(%r{^ExecStart=\/usr\/bin\/aptly api serve -listen=127.0.0.1:9090$}) }
      end
    end

    describe 'enable_cli_and_http' do
      context 'false (default)' do
        it { is_expected.to contain_file('aptly-systemd').without_content(%r{ -no-lock}) }
      end

      context 'true' do
        let(:params) do
          {
            enable_cli_and_http: true
          }
        end

        it { is_expected.to contain_file('aptly-systemd').with_content(%r{ -no-lock}) }
      end
    end
  end

  context 'Using Upstart' do
    let(:facts) do
      {
        operatingsystem: 'Ubuntu',
        operatingsystemrelease: '15.03',
        os: {
          name: 'Ubuntu',
          release: {
            full: '15.03'
          }
        }
      }
    end

    context 'param defaults' do
      let(:params) { {} }

      it do
        is_expected.to contain_file('aptly-upstart')
          .with_path('/etc/init/aptly-api.conf')
          .without_content(%r{^\s*author })
          .with_content(%r{^setuid root$})
          .with_content(%r{^setgid root$})
          .with_content(%r{^exec \/usr\/bin\/aptly api serve -listen=:8080$})
          .that_notifies('Service[aptly-api]')
      end

      it do
        is_expected.to contain_service('aptly-api')
          .with_ensure('running')
          .with_enable(true)
      end
    end

    describe 'ensure' do
      context 'present (default)' do
        let(:params) { {} }

        it { is_expected.to contain_service('aptly-api').with_ensure('running') }
      end

      context 'stopped' do
        let(:params) do
          {
            ensure: 'stopped'
          }
        end

        it { is_expected.to contain_service('aptly-api').with_ensure('stopped') }
      end
    end

    describe 'user' do
      context 'custom' do
        let(:params) do
          {
            user: 'yolo'
          }
        end

        it { is_expected.to contain_file('aptly-upstart').with_content(%r{^setuid yolo$}) }
      end
    end

    describe 'group' do
      context 'custom' do
        let(:params) do
          {
            group: 'yolo'
          }
        end

        it { is_expected.to contain_file('aptly-upstart').with_content(%r{^setgid yolo$}) }
      end
    end

    describe 'listen' do
      context 'custom' do
        let(:params) do
          {
            listen: '127.0.0.1:9090'
          }
        end

        it { is_expected.to contain_file('aptly-upstart').with_content(%r{^exec \/usr\/bin\/aptly api serve -listen=127.0.0.1:9090$}) }
      end
    end

    describe 'log' do
      context 'none (default)' do
        let(:params) { {} }

        it { is_expected.to contain_file('aptly-upstart').with_content(%r{^console none$}) }
      end

      context 'log' do
        let(:params) do
          {
            log: 'log'
          }
        end

        it { is_expected.to contain_file('aptly-upstart').with_content(%r{^console log$}) }
      end
    end

    describe 'enable_cli_and_http' do
      context 'false (default)' do
        it { is_expected.to contain_file('aptly-upstart').without_content(%r{ -no-lock}) }
      end

      context 'true' do
        let(:params) do
          {
            enable_cli_and_http: true
          }
        end

        it { is_expected.to contain_file('aptly-upstart').with_content(%r{ -no-lock}) }
      end
    end
  end
end
