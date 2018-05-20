class ListingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing, only: [:show, :update, :basics, :description, :address, :price, :photos, :calendar, :bankaccount, :publish]
  before_action :access_deny, only: [:basics, :description, :address, :price, :photos, :calendar, :bankaccount, :publish]


  def index
    @listings = current_user.listings
  end

  def show
    @photos = @listing.photos

    @currentUserBooking = Reservation.where("listing_id = ? AND user_id = ?",@listing.id,current_user.id).present? if current_user

    @reviews = @listing.reviews

    @currentUserReview = @reviews.find_by(user_id: current_user.id) if current_user
  end

  def new
    @listing = current_user.listings.build
  end

  def create
    @listing = current_user.listings.build(listing_params)

    if @listing.save
      redirect_to manage_listing_basics_path(@listing), notice: "リスティングを作成・保存をしました"
    else
      redirect_to new_listing_path, notice: "リスティングを作成・保存できませんでした"
    end

  end

  def edit
  end

  def update
    if @listing.update(listing_params)
      redirect_back fallback_location: root_path, notice: "更新できました"
    end
  end

  def basics
  end

  def description
  end

  def address
  end

  def price
  end

  def photos
    @photo = Photo.new
  end

  def calendar
  end

  def bankaccount
    @user = @listing.user
    session[:listing_id] = @listing.id
  end

  def publish
  end

  def not_checked
    @listing = Listing.find(params[:listing_id])
    @listing.update(not_checked: params[:not_checked])
    render :nothing => true
  end


  private

  def listing_params
    params.require(:listing).permit(:car_type, :car_brand, :car_years, :car_size, :price_per_day, :address, :listing_title, :listing_content, :active)
  end

  def set_listing
    @listing = Listing.find(params[:id])
  end

  def access_deny
    if !(current_user == @listing.user)
      redirect_to root_path, notice: "他人の編集ページにはアクセスできません"
    end   
  end
end
