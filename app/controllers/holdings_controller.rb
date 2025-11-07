class HoldingsController < ApplicationController
  before_action :set_holding, only: %i[ show edit update destroy ]

  # GET /holdings or /holdings.json
  def index
    @holdings = Holding.all
  end

  # GET /holdings/1 or /holdings/1.json
  def show
  end

  # GET /holdings/new
  def new
    @holding = Holding.new
  end

  # GET /holdings/1/edit
  def edit
  end

  # POST /holdings or /holdings.json
  def create
    @holding = Holding.new(holding_params)

    respond_to do |format|
      if @holding.save
        format.html { redirect_to @holding, notice: "Holding was successfully created." }
        format.json { render :show, status: :created, location: @holding }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @holding.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /holdings/1 or /holdings/1.json
  def update
    respond_to do |format|
      if @holding.update(holding_params)
        format.html { redirect_to @holding, notice: "Holding was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @holding }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @holding.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /holdings/1 or /holdings/1.json
  def destroy
    @holding.destroy!

    respond_to do |format|
      format.html { redirect_to holdings_path, notice: "Holding was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_holding
      @holding = Holding.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def holding_params
      params.fetch(:holding, {})
    end
end
