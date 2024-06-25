# frozen_string_literal: true

module Discourse
  module Utils
    module AskPassword
      def self.ask_password(prompt)
        CLI::UI::Prompt.ask_password(prompt)
      end

      def self.ask_and_confirm_password(prompt, confirm_prompt)
        password = nil
        loop do
          password = CLI::UI::Prompt.ask_password(prompt)
          password_confirm = CLI::UI::Prompt.ask_password(confirm_prompt)
          return password if password == password_confirm

          CLI::UI::Format "The passwords didn't match. Please try again."
        end
      end
    end
  end
end
