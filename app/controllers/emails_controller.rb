class EmailsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_email, only: [:show, :edit, :update, :destroy]

  # GET /emails
  # GET /emails.json
  def index
    gon.debug = false
    if params[:job_id]
      gon.job_id = params[:job_id]
      gon.debug  = true
    end

    @email_threads = current_user.current_email_threads
  end

  # GET /emails/1
  # GET /emails/1.json
  def show
    if params[:destroy]
      self.destroy
      return
    end
  end

  # GET /emails/new
  def new
    @email = Email.new
  end

  # GET /emails/1/edit
  def edit
  end

  # POST /emails
  # POST /emails.json
  def create
    @email = Email.new(email_params)

    respond_to do |format|
      if @email.save
        format.html { redirect_to @email, notice: 'Email was successfully created.' }
        format.json { render :show, status: :created, location: @email }
      else
        format.html { render :new }
        format.json { render json: @email.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /emails/1
  # PATCH/PUT /emails/1.json
  def update
    respond_to do |format|
      if @email.update(email_params)
        format.html { redirect_to @email, notice: 'Email was successfully updated.' }
        format.json { render :show, status: :ok, location: @email }
      else
        format.html { render :edit }
        format.json { render json: @email.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /emails/1
  # DELETE /emails/1.json
  def destroy
    @email.email_thread.destroy
    respond_to do |format|
      format.html {
        params[:destroy] = false
        redirect_to emails_url, notice: 'Email conversation will no longer be tracked.'
      }
      format.js
    end
  end

  def status
    @percent = (Sidekiq::Status::pct_complete(params[:job_id]) * 100).ceil
    render "shared/progress_bar"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_email
      @email = current_user.emails.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def email_params
      params.require(:email).permit(:user_id, :thread_id, :message_id, :from, :body, :received_on)
    end
end
