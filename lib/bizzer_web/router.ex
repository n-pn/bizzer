defmodule BizzerWeb.Router do
  use BizzerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug BizzerWeb.IdentifyUser
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug BizzerWeb.IdentifyUser
  end

  scope "/quan-ly", BizzerWeb.Admin, as: "admin" do
    pipe_through :browser

    get "/entry/:id", ExportController, :index

    get "/file-anh", AdimageController, :index
    get "/file-anh/thong-ke", AdimageController, :stats

    get "/file-anh/chon-anh", AdimageController, :pick
    get "/file-anh/:adimage", AdimageController, :show

    get "/file-anh/:adimage/chen-logo/:x_offset/:y_offset", AdimageController, :update
    get "/file-anh/:adimage/xoa-anh", AdimageController, :delete
    delete "/file-anh/:adimage", AdimageController, :delete

    get "/tin-dang/", AdentryController, :index

    get "/tin-dang/duyet-tin", AdentryController, :pick
    get "/tin-dang/:adentry/", AdentryController, :show
    get "/tin-dang/:adentry/chap-nhan", AdentryController, :accept
    get "/tin-dang/:adentry/tu-choi", AdentryController, :reject

    put "/tin-dang/:adentry", AdentryController, :update
    post "/tin-dang/:adentry", AdentryController, :update

    get "/tin-dang/:adentry/xoa-tin", AdentryController, :delete
    delete "/tin-dang/:adentry", AdentryController, :delete
  end

  scope "/", BizzerWeb.Public, as: "public" do
    pipe_through :browser

    get "/ve-bizzer-store", SupportController, :about
    get "/quy-che-hoat-dong", SupportController, :policy
    get "/chinh-sach-bao-mat", SupportController, :terms

    get "/dang-nhap", AuthController, :new
    post "/dang-nhap", AuthController, :create
    get "/dang-xuat", AuthController, :destroy

    get "/ca-nhan", UserController, :index
    get "/ca-nhan/:user", UserController, :show
    get "/chuyen-trang", ShopController, :index
    get "/chuyen-trang/:shop", ShopController, :show

    get "/dang-ky", UserController, :new
    post "/dang-ky", UserController, :create
    get "/tao-cua-hang", ShopController, :new
    post "/tao-cua-hang", ShopController, :create

    get "/tai-khoan", UserController, :self

    get "/tai-khoan/sua-thong-tin", UserController, :edit_profile
    post "/tai-khoan/sua-thong-tin", UserController, :update_profile
    put "/tai-khoan/sua-thong-tin", UserController, :update_profile
    get "/tai-khoan/doi-mat-khau", UserController, :edit_password
    post "/tai-khoan/doi-mat-khau", UserController, :update_password
    put "/tai-khoan/doi-mat-khau", UserController, :update_password

    get "/cua-hang", ShopController, :self
    get "/cua-hang/chinh-sua", ShopController, :edit
    post "/cua-hang/chinh-sua", ShopController, :update
    put "/cua-hang/chinh-sua", ShopController, :update
    post "/cua-hang/kich-hoat", ShopController, :activate

    get "/dang-tin", SubmitController, :new
    post "/dang-tin", SubmitController, :create

    get "/rao-vat/:adentry/sua-tin", SubmitController, :edit
    post "/rao-vat/:adentry/sua-tin", SubmitController, :update
    put "/rao-vat/:adentry/sua-tin", SubmitController, :update

    get "/rao-vat/:adentry/xoa-tin", SubmitController, :delete
    get "/rao-vat/:adentry/dung-tin", SubmitController, :stop

    post "/_upload/adimage", UploadController, :adimage
    post "/_upload/generic", UploadController, :generic
    post "/_upload/avatar", UploadController, :avatar
    post "/_upload/cover", UploadController, :cover

    # get "/_filter/grouping", FilterController, :grouping
    # get "/_filter/location", FilterController, :location
    get "/_filter/properties", FilterController, :properties
    # get "/_filter/propvals", FilterController, :propvals

    # get "/_wizard/grouping", WizardController, :grouping
    # get "/_wizard/location", WizardController, :location
    get "/_wizard/properties/:grouping", WizardController, :properties
    # get "/_wizard/propvals", WizardController, :propvals

    get "/_notification", NotificationController, :list

    get "/", SearchController, :front
    get "/:grouping", SearchController, :grouping
    get "/:grouping/:location", SearchController, :location
    get "/:grouping/:location/:adentry", SearchController, :adentry
  end

  # Other scopes may use custom stacks.
  # scope "/api", BizzerWeb do
  #   pipe_through :api
  # end
end
