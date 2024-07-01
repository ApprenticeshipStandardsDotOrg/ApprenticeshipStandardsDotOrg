require "rails_helper"

RSpec.describe "Admin::Synonym", type: :request do
  describe "GET /index" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          create_pair(:synonym)

          sign_in admin
          get admin_synonyms_path

          expect(response).to be_successful
        end

        it "can search" do
          admin = create(:admin)

          sign_in admin
          get admin_synonyms_path(search: "foo")

          expect(response).to be_successful
        end
      end

      context "when converter" do
        it "redirects to root path" do
          admin = create(:user, :converter)

          sign_in admin
          get admin_synonyms_path

          expect(response).to redirect_to root_path
        end
      end

      context "when guest" do
        it "redirects to root path" do
          get admin_synonyms_path

          expect(response).to redirect_to new_user_session_path
        end
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        get admin_synonyms_path

        expect(response).to be_not_found
      end
    end
  end

  describe "GET /show/:id" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          synonym = create(:synonym)

          sign_in admin
          get admin_synonym_path(synonym)

          expect(response).to be_successful
        end
      end

      context "when converter" do
        it "redirects to root path" do
          admin = create(:user, :converter)
          synonym = create(:synonym)

          sign_in admin
          get admin_synonym_path(synonym)

          expect(response).to redirect_to root_path
        end
      end

      context "when guest" do
        it "redirects to root path" do
          synonym = create(:synonym)

          get admin_synonym_path(synonym)

          expect(response).to redirect_to new_user_session_path
        end
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        synonym = create(:synonym)

        get admin_synonym_path(synonym)

        expect(response).to be_not_found
      end
    end
  end

  describe "GET /edit/:id" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          synonym = create(:synonym)

          sign_in admin
          get edit_admin_synonym_path(synonym)

          expect(response).to be_successful
        end
      end

      context "when converter" do
        it "redirects to root path" do
          admin = create(:user, :converter)
          synonym = create(:synonym)

          sign_in admin
          get edit_admin_synonym_path(synonym)

          expect(response).to redirect_to root_path
        end
      end

      context "when guest" do
        it "redirects to root path" do
          synonym = create(:synonym)

          get edit_admin_synonym_path(synonym)

          expect(response).to redirect_to new_user_session_path
        end
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        synonym = create(:synonym)

        get edit_admin_synonym_path(synonym)

        expect(response).to be_not_found
      end
    end
  end

  describe "PUT /update/:id" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        context "with valid params" do
          it "updates record and redirects to show page" do
            admin = create(:admin)
            synonym = create(:synonym, word: "Engineer", synonyms: "Developer")
            expect_any_instance_of(Synonym).to receive(:add_to_elastic_search_synonyms)

            sign_in admin
            patch admin_synonym_path(synonym),
              params: {
                synonym: {
                  word: "Software Engineer",
                  synonyms: "Developer, Dev"
                }
              }
            synonym.reload
            expect(synonym.word).to eq "Software Engineer"
            expect(synonym.synonyms).to eq "Developer, Dev"
            expect(response).to redirect_to admin_synonym_path(synonym)
          end
        end

        context "with invalid params" do
          it "does not update the record and redirects to index" do
            admin = create(:admin)
            synonym = create(:synonym, word: "Engineer", synonyms: "Developer")
            expect_any_instance_of(Synonym).to_not receive(:add_to_elastic_search_synonyms)

            sign_in admin
            patch admin_synonym_path(synonym),
              params: {
                synonym: {
                  word: "",
                  synonyms: "Developer, Dev"
                }
              }
            synonym.reload
            expect(synonym.word).to_not eq "Software Engineer"
            expect(synonym.synonyms).to_not eq "Developer, Dev"
            expect(response).to have_http_status(:unprocessable_content)
          end
        end
      end
    end

    describe "POST /synonyms" do
      context "on admin subdomain", :admin do
        context "when admin user" do
          context "with valid params" do
            it "creates record and redirects to show page" do
              admin = create(:admin)

              sign_in admin

              expect_any_instance_of(Synonym).to receive(:add_to_elastic_search_synonyms)
              expect {
                post admin_synonyms_path,
                  params: {
                    synonym: {
                      word: "Software Engineer",
                      synonyms: "Developer, Dev"
                    }
                  }
              }.to change(Synonym, :count).by(1)

              expect(response).to redirect_to admin_synonym_path(Synonym.last)
            end
          end

          context "with invalid params" do
            it "does not create the record and redirects to index" do
              admin = create(:admin)

              sign_in admin

              expect_any_instance_of(Synonym).to_not receive(:add_to_elastic_search_synonyms)
              expect {
                post admin_synonyms_path,
                  params: {
                    synonym: {
                      word: "",
                      synonyms: "Developer, Dev"
                    }
                  }
              }.to change(Synonym, :count).by(0)

              expect(response).to have_http_status(:unprocessable_content)
            end
          end
        end
      end

      describe "DELETE /synonyms/:id" do
        context "on admin subdomain", :admin do
          context "when admin user" do
            context "with valid params" do
              it "destroys the record and redirects to index page" do
                admin = create(:admin)
                synonym = create(:synonym)

                sign_in admin

                expect_any_instance_of(Synonym).to receive(:remove_from_elastic_search_synonyms)
                expect {
                  delete admin_synonym_path(synonym.id)
                }.to change(Synonym, :count).by(-1)

                expect(response).to redirect_to admin_synonyms_path
              end
            end
          end
        end
      end
    end
  end
end
