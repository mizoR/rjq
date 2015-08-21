require 'spec_helper'

describe Rbq::CLI do
  shared_examples_for 'dump as JSON' do |options|
    context "when extraction the languages' name of 4-characters" do
      let(:argv)   { ['--from', options[:from], script] }
      let(:script) { 'select {|language| language["lang"].length == 4}.map {|language| language["lang"]}' }

      it { expect { cli.run }.to output(JSON.pretty_generate(%w|Java Perl Ruby|) + "\n").to_stdout }
    end
  end

  shared_examples_for 'dump as CSV' do |options|
    context "when extraction the languages inspired over 4 languages, and dump as CSV" do
      let(:argv)   { ['--from', options[:from], '--to', 'csv', script] }
      let(:script) { 'select {|language| language["inspired_by"].length >= 4}.map {|language| [language["lang"], language["inspired_by"].count]}' }

      it do
        expect { cli.run }.to output(CSV.generate {|csv|
          csv << ["C#",         4]
          csv << ["JavaScript", 4]
          csv << ["Perl",       5]
          csv << ["Ruby",       4]
        }).to_stdout
      end
    end
  end

  shared_examples_for 'dump as TSV' do |options|
    context "when extraction the languages inspired over 4 languages, and dump as TSV" do
      let(:argv)   { ['--from', options[:from], '--to', 'tsv', script] }
      let(:script) { 'select {|language| language["inspired_by"].length >= 4}.map {|language| [language["lang"], language["inspired_by"].count]}' }

      it do
        expect { cli.run }.to output(CSV.generate(col_sep: "\t") {|csv|
          csv << ["C#",         4]
          csv << ["JavaScript", 4]
          csv << ["Perl",       5]
          csv << ["Ruby",       4]
        }).to_stdout
      end
    end
  end

  before do
    allow($stdin).to receive(:tty?).and_return(false)
    allow($stdin).to receive(:read).and_return(data)

    allow($stdout).to receive(:tty?).and_return(false)
  end

  let(:cli) { described_class.new(argv) }

  let(:languages) do
    [
      {lang: 'C',          born_in: 1973, inspired_by: %w|Algol B|},
      {lang: 'C++',        born_in: 1980, inspired_by: %w|C Simula Algol|},
      {lang: 'C#',         born_in: 2000, inspired_by: %w|Delphi Java C++ Ruby|},
      {lang: 'Java',       born_in: 1994, inspired_by: %w|C++ Objective-C C#|},
      {lang: 'JavaScript', born_in: 1995, inspired_by: %w|C Self awk Perl|},
      {lang: 'Perl',       born_in: 1987, inspired_by: %w|C shell AWK sed LISP|},
      {lang: 'PHP',        born_in: 1995, inspired_by: %w|Perl C|},
      {lang: 'Python',     born_in: 1991, inspired_by: %w|ABC Perl Modula-3|},
      {lang: 'Ruby',       born_in: 1995, inspired_by: %w|Perl Smalltalk LISP CLU|},
    ].map(&:stringify_keys)
  end

  describe '#run' do
    subject { capture(:stdout) { cli.run } }

    describe 'import as JSON' do
      let(:data)   { JSON.generate(languages) }

      it_behaves_like 'dump as JSON', from: 'json'

      it_behaves_like 'dump as CSV', from: 'json'

      it_behaves_like 'dump as TSV', from: 'json'
    end
  end
end
