require 'date'
require 'archive/zip'
require 'progress_bar'
require 'highline'
require "highline/import"

module Forensic
  module Zip
    class Bruteforce
      
      def initialize(file, list)
        self.file = file
        self.list = list
        @dest = 'unzip_'.concat( DateTime.now.strftime("%Y%m%d%H%M%S").to_s )
        @bar  = nil
      end
      
      def file= file
        unless file.nil?
          if file_exist? file
            @file = file
          end
        else
          raise 'Please enter a zip file'
        end
      end
      
      def list= list
        unless list.nil?
          if file_exist? list
            @list = list
          end
        else
          raise 'Please enter a txt file'
        end
      end
      
      def crack
        begin
          @bar = ProgressBar.new(num_line_list)
          File.foreach(@list) { |pass|
              @bar.increment!
              pass = pass.gsub(/\n/,"")
              if extract(pass) == true then
                say "\n\n[+] Password found: #{pass}"
                say "[+] Files unzipped in: ./#{@dest}\n\n"
                exit # stop scritp
              end
          }
          say "\n\n[+] Password not found!\n\n"
        rescue StandardError => e
          say "\n\n[-] Failure: #{e}\n\n"
        end
      end
      
      private
      
        def num_line_list
          count = 0
          File.open(@list) {|f| count = f.read.count("\n")}
          count
        end
      
        def file_exist? file
          unless File.exist? file
            raise "File #{file} not found."
            false
          else
            true
          end
        end
      
        def extract pass
          begin
            Archive::Zip.extract(@file, @dest, password: pass)
            return true
          rescue
            FileUtils.rm_rf(@dest)
            return false
          end
        end
      
    end
  end
end