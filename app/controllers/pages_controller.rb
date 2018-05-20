class PagesController < ApplicationController
  def index #views/index.html.erbを表示させるというアクション
    @users = User.all
  end

  def search
    if params[:search].present?
      
      if params["lat"].present? & params["lng"].present? 
        @latitude = params["lat"]
        @longitude = params["lng"]

        geolocation = [@latitude,@longitude]
      else
        geolocation = Geocoder.coordinates(params[:search])
        @latitude = geolocation[0]
        @longitude = geolocation[1]
      end

      @listings = Listing.where(active: true).near(geolocation, 1, order: 'distance')

    # 検索欄が空欄の場合
    else

      @listings = Listing.where(active: true).all
      @latitude = @listings.to_a[0].latitude
      @longitude = @listings.to_a[0].longitude  

    end

    # Ransack q のチェックボックス一覧
    if params[:q].present? 

      if params[:q][:price_per_day_gteq].present?
        session[:price_per_day_gteq] = params[:q][:price_pernight_gteq]
      else
        session[:price_per_day_gteq] = nil
      end

      
      if params[:q][:price_per_day_lteq].present?
        session[:price_per_day_lteq] = params[:q][:price_pernight_lteq]
      else
        session[:price_per_day_lteq] = nil
      end

      if params[:q][:car_type_eq_any].present?
        session[:car_size_eq_any] = params[:q][:car_size_eq_any]
        session[:Middle] = session[:car_size_eq_any].include?("中型")
        session[:Small] = session[:car_size_eq_any].include?("小型")
        session[:Big] = session[:car_size_eq_any].include?("大型")
      else
        session[:home_type_eq_any] = ""
        session[:Middle] = false
        session[:Small] = false
        session[:Big] = false
      end

      if params[:q][:car_type_eq].present?
        session[:car_type_eq] = params[:q][:car_type_eq]
      else
        session[:car_type_eq] = nil
      end


      if params[:q][:car_years_gteq].present?
        session[:car_years_gteq] = params[:q][:car_years_gteq]
      else
        session[:car_years_gteq] = nil
      end

    end 

    # Q条件をまとめたものをセッションQに入れる
    session[:q] = {"price_per_day_gteq"=>session[:price_per_day_gteq], "price_per_day_lteq"=>session[:price_per_day_lteq],  "car_type_eq_any"=>session[:car_type_eq_any], "car_type_eq"=>session[:car_brand_eq], "car_years_gteq"=>session[:car_years_gteq]}


    # ransack検索
    @search = @listings.ransack(session[:q])
    @result = @search.result(distinct: true)

     #リスティングデータを配列にしてまとめる 
    @arrlistings = @result.to_a

    # start_date end_dateの間に予約がないことを確認.あれば削除
    if ( !params[:start_date].blank? && !params[:end_date].blank? )

      session[:start_date] = params[:start_date]
      session[:end_date] = params[:end_date]

      start_date = Date.parse(session[:start_date])
      end_date = Date.parse(session[:end_date])

      @listings.each do |listing|

        # check the listing is availble between start_date to end_date
        unavailable = listing.reservations.where(
            "(? <= start_date AND start_date <= ?)
              OR (? <= end_date AND end_date <= ?) 
              OR (start_date < ? AND ? < end_date)",
            start_date, end_date,
            start_date, end_date,
            start_date, end_date
        ).limit(1)

        # delete unavailable room from @listings
        if unavailable.length > 0
          @arrlistings.delete(listing) 
        end 
      end
    end
  end

  def ajaxsearch
    
    # まずajaxで送られてきた緯度経度をセッションに入れる
    if !params[:geolocation].blank?
      geolocation = params[:geolocation]
    end

    @listings = Listing.where(active: true).near(geolocation, 1, order: 'distance')

    #リスティングデータを配列にしてまとめる 
    @arrlistings = @listings.to_a

    # start_date end_dateの間に予約がないことを確認.あれば削除
    if ( !session[:start_date].blank? && !session[:end_date].blank? )

      start_date = Date.parse(session[:start_date])
      end_date = Date.parse(session[:end_date])

      @listings.each do |listing|

        # check the listing is availble between start_date to end_date
        unavailable = listing.reservations.where(
            "(? <= start_date AND start_date <= ?)
              OR (? <= end_date AND end_date <= ?) 
              OR (start_date < ? AND ? < end_date)",
            start_date, end_date,
            start_date, end_date,
            start_date, end_date
        ).limit(1)

        # delete unavailable room from @listings
        if unavailable.length > 0
          @arrlistings.delete(listing) 
        end 
      end
    end

    respond_to :js
  
  end
end
