class CreatorsController < ApplicationController
  PAGE_SIZE = 10

  def index
    @page = (params[:page] || 0).to_i

    if params[:keywords].present?
      @keywords = params[:keywords]
      creator_search = CreatorSearch.new(@keywords)

      @creators = Creator.where(creator_search.where_clause, creator_search.where_args)
                      .order(creator_search.order)
                      .offset(PAGE_SIZE * @page).limit(PAGE_SIZE)
    else
      @creators = []
    end

    respond_to do |format|
      format.html {}
      format.json { render json: @creators }
    end
  end

  def show
    creator_detail = CreatorDetail.find(params[:id])
    respond_to do |format|
      format.json { render json: creator_detail }
    end
  end
end