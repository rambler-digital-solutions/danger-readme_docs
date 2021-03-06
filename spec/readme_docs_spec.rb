# frozen_string_literal: true

require File.expand_path('spec_helper', __dir__)

module Danger
  describe Danger::DangerReadmeDocs do
    it 'should be a plugin' do
      expect(Danger::DangerReadmeDocs.new(nil)).to be_a Danger::Plugin
    end

    #
    # You should test your custom attributes and methods here
    #
    describe 'with Dangerfile' do
      subject do
        @readme_docs.lint
        @readme_docs.status_report[:warnings]
      end

      let(:fake_new_readme_path) { 'spec/fixtures/README.md' }
      let(:fake_main_readme) { '# Test \n spec/fixtures/README.md' }
      let(:is_files_readable) { true }

      before do
        @readme_docs = testing_dangerfile.readme_docs

        allow(@readme_docs.git).to receive(:added_files).and_return([])
        allow(@readme_docs.git).to receive(:modified_files).and_return([fake_new_readme_path])
        allow(File).to receive(:read).with('README.md').and_return(fake_main_readme)
        allow(File).to receive(:readable?).and_return(is_files_readable)
      end

      it { is_expected.to be_empty }

      context 'when yml file changed' do
        let(:fake_main_readme) { '# Test \n spec/fixtures/README.yml' }
        let(:fake_new_readme_path) { 'spec/fixtures/readme.yml' }

        it { is_expected.to be_empty }
      end

      context 'when file is not readme' do
        let(:fake_main_readme) { '# Test' }
        let(:fake_new_readme_path) { 'spec/fixtures/readmessio.yml' }

        it { is_expected.to be_empty }
      end

      context 'when file name added in lower case' do
        let(:fake_main_readme) { '# Test \n spec/fixtures/readme.md' }
        let(:fake_new_readme_path) { 'spec/fixtures/README.md' }

        it { is_expected.to be_empty }
      end

      context 'when with multiple readmes' do
        let(:fake_main_readme) { '# Test' }
        let(:fake_new_readmes) do
          [
            'spec/fixtures/README.md',
            'spec/random/README.md',
            'random/random/README.md'
          ]
        end
        let(:warning) do
          'Please add mentions of sub readme files ' \
          "in main README.md:\n **spec/fixtures/README.md<br/>" \
          'spec/random/README.md<br/>random/random/README.md**'
        end

        before do
          allow(@readme_docs.git).to receive(:modified_files).and_return(fake_new_readmes)
        end

        it { is_expected.to eq([warning]) }
      end

      context 'without mention in main README' do
        let(:fake_main_readme) { '# Test' }
        let(:warning) do
          'Please add mentions of sub readme files ' \
          "in main README.md:\n **spec/fixtures/README.md**"
        end

        it { is_expected.to eq([warning]) }

        context 'when files are not readable' do
          let(:is_files_readable) { false }

          it { is_expected.to be_empty }
        end
      end
    end
  end
end
