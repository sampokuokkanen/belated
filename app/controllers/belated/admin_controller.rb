class Belated
  # Controller in charge of admin side of Belated.
  class AdminController < ::ActionController::Base

    if (name = Belated.basic_auth.name) && (pass = Belated.basic_auth.password)
      http_basic_authenticate_with name: name, password: pass
    end

    def index
      return unless request.post?

      @belated = Belated.find params[:job_id]
    end

    def future_jobs
      @belateds = Belated.all_future_jobs
    end
  end
end
