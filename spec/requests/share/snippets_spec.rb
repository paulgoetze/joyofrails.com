require "rails_helper"

RSpec.describe "/snippets", type: :request do
  describe "GET /index" do
    it "renders a successful response" do
      FactoryBot.create(:snippet)
      get share_snippets_url
      expect(response).to be_successful
    end

    it "does not render the New Snippet button when not allowed" do
      get share_snippets_url

      expect(page).to_not have_content("New Snippet")
    end

    it "renders the New Snippet button when allowed" do
      Flipper.enable(:snippets, login_as_user)
      get share_snippets_url

      expect(page).to have_content("New Snippet")
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      snippet = FactoryBot.create(:snippet)
      get share_snippet_url(snippet)
      expect(response).to be_successful
    end

    it "does not render the Edit Snippet button when not allowed" do
      Flipper.enable(:snippets, login_as_user)
      snippet = FactoryBot.create(:snippet)
      get share_snippet_url(snippet)

      expect(page).to_not have_content("Edit this snippet")
    end

    it "renders the Edit Snippet button when allowed" do
      user = login_as_user
      Flipper.enable(:snippets, user)
      snippet = FactoryBot.create(:snippet, author: user)
      get share_snippet_url(snippet)

      expect(page).to have_content("Edit this snippet")
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      Flipper.enable(:snippets, login_as_user)
      get new_share_snippet_url
      expect(response).to be_successful
    end

    it "redirects when not authenticated" do
      Flipper.enable(:snippets)
      get new_share_snippet_url
      expect(response).to be_not_found
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      user = login_as_user
      Flipper.enable(:snippets, user)
      snippet = FactoryBot.create(:snippet, author: user)
      get edit_share_snippet_url(snippet)
      expect(response).to be_successful
    end

    it "renders a 404" do
      login_as_user
      Flipper.enable(:snippets)
      snippet = FactoryBot.create(:snippet)
      get edit_share_snippet_url(snippet)
      expect(response).to be_not_found
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      before do
        Flipper.enable(:snippets, login_as_user)
      end

      it "creates a new Snippet" do
        expect {
          post share_snippets_url, params: {snippet: {source: "puts \"Hello!\"", language: "ruby"}}
        }.to change(Snippet, :count).by(1)
      end

      it "associates snippet with the current user" do
        user = login_as_user
        Flipper.enable(:snippets, user)

        post share_snippets_url, params: {snippet: {source: "puts \"Hello!\"", language: "ruby"}}

        expect(Snippet.last.author).to eq(user)
      end

      it "redirects back to the edit page" do
        post share_snippets_url, params: {snippet: {source: "puts \"Hello!\"", language: "ruby"}}
        expect(response).to redirect_to(edit_share_snippet_url(Snippet.last))
      end

      it "redirects to the screenshot page" do
        post share_snippets_url, params: {snippet: {source: "puts \"Hello!\"", language: "ruby"}, commit: "Share"}
        expect(response).to redirect_to(new_share_snippet_screenshot_url(Snippet.last, auto: true))
      end
    end

    context "with invalid parameters" do
      before do
        Flipper.enable(:snippets, login_as_user)
      end

      it "does not create a new Snippet" do
        expect {
          post share_snippets_url, params: {snippet: {}}
        }.to change(Snippet, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post share_snippets_url, params: {snippet: {}}
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when not authenticated" do
      it "renders a 404" do
        post share_snippets_url, params: {snippet: {}}
        expect(response).to be_not_found
      end
    end

    context "when not authorized" do
      it "renders a 404" do
        Flipper.disable(:snippets, login_as_user)

        post share_snippets_url, params: {snippet: {}}
        expect(response).to be_not_found
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      it "updates the requested snippet" do
        user = login_as_user
        Flipper.enable(:snippets, user)
        snippet = FactoryBot.create(:snippet, author: user)
        patch share_snippet_url(snippet), params: {snippet: {source: "puts \"Goodbye!\""}}
        snippet.reload
        expect(snippet.source).to eq("puts \"Goodbye!\"")
      end

      it "redirects back to the edit page" do
        user = login_as_user
        Flipper.enable(:snippets, user)
        snippet = FactoryBot.create(:snippet, author: user)
        patch share_snippet_url(snippet), params: {snippet: {source: "puts \"Goodbye!\""}}
        snippet.reload
        expect(response).to redirect_to(edit_share_snippet_url(snippet))
      end

      it "redirects to the screenshot page" do
        user = login_as_user
        Flipper.enable(:snippets, user)
        snippet = FactoryBot.create(:snippet, author: user)
        patch share_snippet_url(snippet), params: {snippet: {source: "puts \"Goodbye!\""}, commit: "Share"}
        snippet.reload
        expect(response).to redirect_to(new_share_snippet_screenshot_url(snippet, auto: true))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        user = login_as_user
        Flipper.enable(:snippets, user)
        snippet = FactoryBot.create(:snippet, author: user)
        patch share_snippet_url(snippet), params: {snippet: {language: "does_not_exist"}}
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when not authenticated" do
      it "renders a 404" do
        snippet = FactoryBot.create(:snippet)
        patch share_snippet_url(snippet), params: {snippet: {language: "javascript"}}
        expect(response).to be_not_found
        expect(snippet.reload.language).to_not eq("javascript")
      end
    end

    context "when not authorized" do
      it "renders a 404" do
        snippet = FactoryBot.create(:snippet, author: login_as_user)
        patch share_snippet_url(snippet), params: {snippet: {language: "javascript"}}
        expect(response).to be_not_found
        expect(snippet.reload.language).to_not eq("javascript")
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested snippet" do
      user = login_as_user
      Flipper.enable(:snippets, user)
      snippet = FactoryBot.create(:snippet, author: user)

      expect {
        delete share_snippet_url(snippet)
      }.to change(Snippet, :count).by(-1)
    end

    it "redirects to the snippets list" do
      user = login_as_user
      Flipper.enable(:snippets, user)
      snippet = FactoryBot.create(:snippet, author: user)

      expect {
        delete share_snippet_url(snippet)
      }.to change(Snippet, :count).by(-1)

      expect { snippet.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect(response).to redirect_to(share_snippets_url)
    end

    context "when not authenticated" do
      it "renders a 404" do
        snippet = FactoryBot.create(:snippet)
        delete share_snippet_url(snippet)
        expect(response).to be_not_found
        expect(snippet.reload).to eq(snippet)
      end
    end

    context "when not authorized" do
      it "renders a 404" do
        snippet = FactoryBot.create(:snippet, author: login_as_user)
        delete share_snippet_url(snippet)
        expect(response).to be_not_found
        expect(snippet.reload).to eq(snippet)
      end
    end
  end
end
