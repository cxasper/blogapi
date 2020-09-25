require 'rails_helper'
require 'byebug'

RSpec.describe 'Posts', type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:user_post) { create(:post, user: user) }
  let!(:other_user_post) { create(:post, user: other_user, published: true) }
  let!(:other_user_post_draft) { create(:post, user: other_user, published: false) }
  let!(:auth_headers) { { 'Authorization' => "Bearer #{user.auth_token}"} }
  let!(:other_auth_headers) { { 'Authorization' => "Bearer #{other_user.auth_token}"} }
  let(:create_params) { { 'post' => { 'title' => 'title', 'content' => 'content', 'published'  => true } } }
  let(:update_params) { { 'post' => { 'title' => 'title', 'content' => 'content', 'published'  => true } } }
  # Authorization: Bearer token

  describe 'GET /posts/{id}' do
    context 'with valid auth' do
      context "when request other's autor post" do
        context 'when post is public' do
          before { get "/posts/#{other_user_post.id}", headers: auth_headers }

          context 'payload' do
            subject { payload }
            it { is_expected.to include('id') }
          end

          context 'response' do
            subject { response }
            it { is_expected.to have_http_status(:ok) }
          end
        end

        context 'when post is draft' do
          before { get "/posts/#{other_user_post_draft.id}", headers: auth_headers }

          context 'payload' do
            subject { payload }
            it { is_expected.to include(:error) }
          end

          context 'response' do
            subject { response }
            it { is_expected.to have_http_status(:not_found) }
          end
        end
      end
      context "when request user's post" do

      end
    end
  end

  describe 'POST /posts' do
    context 'with auth' do
      before { post '/posts', params: create_params, headers: auth_headers }

      context 'payload' do
        subject { payload }
        it { is_expected.to include(:id, :title, :content, :published, :author) }
      end

      context 'response' do
        subject { response }
        it { is_expected.to have_http_status(:created) }
      end
    end
    context 'without auth' do
      before { post '/posts', params: create_params }

      context 'payload' do
        subject { payload }
        it { is_expected.to include(:error) }
      end

      context 'response' do
        subject { response }
        it { is_expected.to have_http_status(:unauthorized) }
      end
    end
  end

  describe 'PUT /posts/{id}' do
    context 'with auth' do
      context 'update my post' do
        before { put "/posts/#{user_post.id}", params: update_params, headers: auth_headers }

        context 'payload' do
          subject { payload }
          it { is_expected.to include(:id, :title, :content, :published, :author) }
          it { expect(payload[:id]).to eq(user_post.id) }
        end

        context 'response' do
          subject { response }
          it { is_expected.to have_http_status(:ok) }
        end
      end

      context 'update other post' do
        before { put "/posts/#{other_user_post.id}", params: update_params, headers: auth_headers }

        context 'payload' do
          subject { payload }
          it { is_expected.to include(:error) }
        end

        context 'response' do
          subject { response }
          it { is_expected.to have_http_status(:not_found) }
        end
      end
    end

    context 'without invalid auth' do
      before { put "/posts/#{user_post.id}", params: update_params }

      context 'payload' do
        subject { payload }
        it { is_expected.to include(:error) }
      end

      context 'response' do
        subject { response }
        it { is_expected.to have_http_status(:unauthorized) }
      end
    end
  end

  private

  def payload
    JSON.parse(response.body).with_indifferent_access
  end
end
