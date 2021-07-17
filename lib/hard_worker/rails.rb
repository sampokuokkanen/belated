class HardWorker
  class Rails < ::Rails::Engine
    class Reloader
      def initialize(app = ::Rails.application)
        @app = app
      end

      def call(&block)
        @app.reloader.wrap(&block)
      end

      def inspect
        "#<HardWorker::Rails::Reloader @app=#{@app.class.name}>"
      end
    end
  end
end
