# frozen_string_literal: true

module Discourse
  module Utils
    module AskPassword
      def self.ask_password(prompt)
        CLI::UI::Prompt.ask_password(prompt)
      end

      def self.ask_and_confirm_password(prompt, confirm_prompt, mismatch_prompt)
        password = nil
        mismatch = false
        loop do
          prompt = prompt_text(prompt, mismatch_prompt, mismatch:)
          password = CLI::UI::Prompt.ask_password(prompt)
          password_confirm = CLI::UI::Prompt.ask_password(confirm_prompt)
          return password if password == password_confirm

          mismatch = true
        end
      end

      def self.prompt_text(prompt, mismatch_prompt, mismatch: false)
        mismatch ? "#{mismatch_prompt}\n  #{prompt}" : prompt
      end
    end
  end
end
