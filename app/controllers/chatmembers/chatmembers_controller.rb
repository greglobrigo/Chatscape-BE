class Chatmembers::ChatmembersController < ApplicationController
    def test
        render json: {message: "ChatMembers controller is working"}, status: :ok
    end
end
