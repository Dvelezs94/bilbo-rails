class ErrorController < ApplicationController

    def not_found
      respond_to do |format|
        format.html { render status: 404 }
      end
    end
  
    def internal_error
      respond_to do |format|
        format.html { render status: 500 }
      end
    end
end
