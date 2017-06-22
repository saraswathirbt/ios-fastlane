module Fastlane
  module Actions
    class CniGitAddAction < Action
      def self.run(params)
        if !params[:path].nil?
          if params[:path].kind_of?(String)
            paths = params[:path].shellescape
          else
            paths = params[:path].map(&:shellescape).join(' ')
          end
        elsif !params[:all].nil?
          paths = "."
        elsif !params[:pathspec].nil?
          paths = params[:pathspec].shellescape
        end

        result = Actions.sh("git add #{paths}")
        UI.success("Successfully added \"#{params[:all].nil? ? params[:path] : "all files"}\" 💾.")

        return result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Directly add the given file"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       description: "The file you want to add",
                                       is_string: false,
                                       conflicting_options: [:pathspec, :all],
                                       optional: true,
                                       verify_block: proc do |value|
                                         if value.kind_of?(String)
                                           UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                         else
                                           value.each do |x|
                                             UI.user_error!("Couldn't find file at path '#{x}'") unless File.exist?(x)
                                           end
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :pathspec,
                                       description: "The pathspec you want to add",
                                       is_string: true,
                                       conflicting_options: [:path, :all],
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :all,
                                       description: "The option to add all files",
                                       is_string: false,
                                       conflicting_options: [:pathspec, :path],
                                       optional: true)
        ]
      end

      def self.return_value
        nil
      end

      def self.authors
        ["4brunu", "Antondomashnev"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'cni_git_add(path: "./version.txt")',
          'cni_git_add(path: ["./version.txt", "./changelog.txt"])',
          'cni_git_add(pathspec: "*.txt")',
          'cni_git_add(pathspec: "Frameworks/*")',
          'cni_git_add(all: true)'
        ]
      end

      def self.category
        :source_control
      end
    end
  end
end
