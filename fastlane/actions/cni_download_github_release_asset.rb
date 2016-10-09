module Fastlane
  module Actions
    class CniDownloadGithubReleaseAssetAction < Action
      def self.run(params)
        require 'open-uri'
        require 'fileutils'

        destination_path = File.expand_path(params[:destination_path].shellescape)
        dirname = File.dirname(destination_path)
        unless File.directory?(dirname)
          FileUtils.mkdir_p(dirname)
        end

        UI.important "⏬  Downloading asset #{params[:asset_url]} to #{destination_path}..."
        begin
          api_token = params[:api_token]
          asset_url = params[:asset_url]
          request_url = "#{asset_url}?access_token=#{api_token}"
          step = 0
          partial = 0
          progress = 0
          File.open(destination_path, "wb") do |saved_file|
            # the following "open" is provided by open-uri
            open(request_url, "User-Agent" => "fastlane-cni_download_github_release_asset", "Accept" => "application/octet-stream", :content_length_proc => lambda {|t|
              if t && 0 < t
                step = t / 10
                partial = step
                formatted_file_size = '%.2f' % (t.to_f / 2**20)
                UI.important("Total size: #{formatted_file_size} MB")
              end
            },
            :progress_proc => lambda {|s|
              if s > partial
                partial += step
                if step > 0
                  UI.message "#{progress}%"
                  progress = (partial / step) * 10
                end
              end

            }) { |read_file|
              saved_file.write(read_file.read)
            }
            end

          compressed_file_size = File.size(params[:destination_path]).to_f / 2**20
          formatted_file_size = '%.2f' % compressed_file_size
          UI.success "Download finished, total size: #{formatted_file_size} MB ✅"
        rescue => ex
          UI.user_error!("Error fetching releases_asset: #{ex}")
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Download a file from a remote server (e.g. ZIP file)"
      end

      def self.details
        "This action downloads a file from an HTTP/HTTPS url and puts it in a destination path.\nIf the file has been previously downloaded, it will be overrided."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :asset_url,
                                       env_name: "FL_ASSET_GITHUB_URL",
                                       description: "The URL to the desired asset in GitHub API",
                                       verify_block: proc do |value|
                                          UI.important("The URL doesn't start with http or https") unless value.start_with?("http")
                                       end),
          FastlaneCore::ConfigItem.new(key: :destination_path,
                                       env_name: "FL_DESTINATION_PATH",
                                       description: "The directory to which save file"),
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "FL_GITHUB_API_TOKEN",
                                       description: "Personal API Token for GitHub - generate one at https://github.com/settings/tokens",
                                       is_string: true,
                                       optional: false),
        ]
      end

      def self.authors
        ["antondomashnev"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
