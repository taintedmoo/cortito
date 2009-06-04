# Copyright (c) 2009, Adrian Kosmaczewski / akosma software
# All rights reserved.
# BSD License. See LICENSE.txt for details.

class ItemsController < ApplicationController

  def redirect
    @item = Item.find_by_shortened(params[:shortened])
    if @item
      redirect_to @item.original
    else
      redirect_to :shorten
    end
  end

  def shorten
    if request.get?
      render :template => "items/new"
    else
      url = params[:url]
      
      if !params.has_key?(:url) || url.length == 0
        render :template => "items/invalid"
      else
        shortened_url_prefix = ["http://tinyurl.com", 
          "http://u.nu", "http://snipurl.com/", "http://readthisurl.com/",
          "http://doiop.com/", "http://urltea.com/", "http://dwarfurl.com/", 
          "http://memurl.com/", "http://shorl.com/", "http://traceurl.com/"]
        
        shortened_url_prefix.each do |prefix|
          if url.starts_with?(prefix)
            render :template => "items/invalid"
            return
          end
        end
        
        @item = Item.find_by_original(url)
        if not @item
          @item = Item.new
          @item.original = params[:url]
          @item.save
        end
      
        host = request.host_with_port
      
        respond_to do |format|
          format.html do
            @short_url = ["http://", host, "/", @item.shortened].join
            render :template => "items/show"
          end
          format.xml { render :text => ["http://", host, "/", @item.shortened].join }
          format.js { render :text => ["http://", host, "/", @item.shortened].join }
        end
      
      end

    end
  end

end
