class Belated
  # Controller in charge of admin side of Belated.
  # TODO: Rename it
  class BelatedController < ::ActionController::Base
    def index
      return unless request.post?

      @belated = Belated.find params[:job_id]
    end
  end
end
