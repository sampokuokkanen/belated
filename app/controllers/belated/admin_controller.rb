class Belated
  # Controller in charge of admin side of Belated.
  class AdminController < ::ActionController::Base
    def index
      return unless request.post?

      @belated = Belated.find params[:job_id]
    end

    def future_jobs; end
  end
end
