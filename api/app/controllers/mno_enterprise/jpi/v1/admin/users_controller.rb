module MnoEnterprise
  class Jpi::V1::Admin::UsersController < Jpi::V1::Admin::BaseResourceController

    # GET /mnoe/jpi/v1/admin/users
    def index
      @users = MnoEnterprise::User
      @users = @users.limit(params[:limit]) if params[:limit]
      @users = @users.skip(params[:offset]) if params[:offset]
      @users = @users.order_by(params[:order_by]) if params[:order_by]
      @users = @users.where(params[:where]) if params[:where]
      @users = @users.all

      response.headers['X-Total-Count'] = @users.metadata[:pagination][:count]
    end

    # GET /mnoe/jpi/v1/admin/users/1
    def show
      @user = MnoEnterprise::User.find(params[:id])
      @user_organizations = @user.organizations
    end

    # POST /mnoe/jpi/v1/admin/users
    def create
      @user = MnoEnterprise::User.build(user_create_params)
      @user.admin_role = params[:user][:admin_role].presence

      if @user.save
        render :show
      else
        render json: @user.errors, status: :bad_request
      end
    end

    # PATCH /mnoe/jpi/v1/admin/users/:id
    def update
      @user = MnoEnterprise::User.find(params[:id])
      @user.update(user_params)

      render :show
    end

    # DELETE /mnoe/jpi/v1/admin/users/1
    def destroy
      user = MnoEnterprise::User.find(params[:id])
      user.destroy

      head :no_content
    end

    private

    def user_params
      params.require(:user).permit(:admin_role)
    end

    def user_create_params
      params.require(:user).permit(:name, :surname, :email, :phone).merge(
        password: 'Password1',
        confirmed_at: Time.zone.now
      )
    end
  end
end
