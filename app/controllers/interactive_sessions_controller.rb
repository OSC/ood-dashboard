class InteractiveSessionsController < ApplicationController
  # GET /interactive_sessions
  # GET /interactive_sessions.json
  def index
    @interactive_sessions = InteractiveSession.all
    @new_interactive_session = InteractiveSession.new
  end

  # POST /interactive_sessions
  # POST /interactive_sessions.json
  def create
    @interactive_session = InteractiveSession.new(interactive_session_params)

    respond_to do |format|
      if @interactive_session.save
        format.html { redirect_to interactive_sessions_url, notice: 'Interactive session was successfully created.' }
        format.json { render :show, status: :created, location: @interactive_session }
      else
        format.html { render action: 'index' }
        format.json { render json: @interactive_session.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /interactive_sessions/1
  # DELETE /interactive_sessions/1.json
  def destroy
    @interactive_session = InteractiveSession.find(params[:id])
    @interactive_session.destroy
    respond_to do |format|
      format.html { redirect_to interactive_sessions_url, notice: 'Interactive session was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def interactive_session_params
      # params.fetch(:interactive_session, {})
      params.require(:interactive_session).permit!
    end
end
