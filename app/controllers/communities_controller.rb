class CommunitiesController < ApplicationController
  before_action :set_community, only: [:show, :edit, :update, :destroy]

  # GET /communities
  def index
    @communities = Community.all
  end

  # GET /communities/1
  def show
  end

  # GET /communities/new
  def new
    @community = Community.new
  end

  # GET /communities/1/edit
  def edit
  end

  # POST /communities
  def create
    @community = Community.new(community_params)

    if @community.save
      redirect_to @community, notice: 'Community was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /communities/1
  def update
    if @community.update(community_params)
      redirect_to @community, notice: 'Community was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /communities/1
  def destroy
    @community.destroy
    redirect_to communities_url, notice: 'Community was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_community
      @community = Community.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def community_params
      params.require(:community).permit(:fbid, :name)
    end
end
