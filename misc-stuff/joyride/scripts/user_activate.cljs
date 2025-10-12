(ns user-activate
  (:require ["vscode" :as vscode]
            [joyride.core :as joyride]
            [promesa.core :as p]))

;; This is the Joyride User `activate.cljs` script. It will run
;; as the first thing when Joyride is activated, making it a good
;; place for you to initialize things. E.g. install event handlers,
;; print motivational messages, or whatever.

;; You can run this and other User scripts with the command:
;;   *Joyride: Run User Script*

;;; REPL practice
(comment
  ;; Use Calva to start the Joyride REPL and connect it. The command:
  ;;   *Calva: Start Joyride REPL and Connect*
  ;; Then evaluate some code in this Rich comment block. Or just write
  ;; some new code and evaluate that. Or whatever. It's fun!

  ;; New to Calva and/or Clojure? Use the Calva command:
  ;;   *Calva: Fire up the Getting Started REPL*
  ;; It will guide you through the basics.

  (-> 4
      (* 10)
      (+ 1)
      inc)

  (p/let [choice (vscode/window.showInformationMessage "Be a Joyrider 🎸" "Yes" "Of course!")]
    (if choice
      (.appendLine (joyride/output-channel)
                   (str "You choose: " choice " 🎉"))
      (.appendLine (joyride/output-channel)
                   "You just closed it? 😭"))))

;;; Output channel pop-up
;; This following code is why you see the Joyride output channel
;; on startup.

#_(doto (joyride/output-channel)
    (.show true) ;; specifically this line. It shows the channel.
    (.appendLine "Welcome Joyrider! This is your User activation script speaking.")
    (.appendLine "Tired of this message popping up? It's the script doing it. Edit it away!")
    (.appendLine "Hint: There is a command: **Open User Script...**"))

;;; user_activate.cljs skeleton

;; Keep tally on VS Code disposables we register
(defonce !db (atom {:disposables []}))

;; To make the activation script re-runnable we dispose of
;; event handlers and such that we might have registered
;; in previous runs.
(defn- clear-disposables! []
  (run! (fn [disposable]
          (.dispose disposable))
        (:disposables @!db))
  (swap! !db assoc :disposables []))

;; Pushing the disposables on the extension context's
;; subscriptions will make VS Code dispose of them when the
;; Joyride extension is deactivated, or when you rerun
;; `my-main` in this ns (such as rerunning this script).
(defn- push-disposable! [disposable]
  (swap! !db update :disposables conj disposable)
  (-> (joyride/extension-context)
      .-subscriptions
      (.push disposable)))

(defn- my-main []
  #_(println "Hello World, from my-main in user_activate.cljs script")
  (clear-disposables!) ;; Any disposables add with `push-disposable!`
  ;; will be cleared now. You can push them anew.

  ;;; require my-lib
  (require '[my-lib])

  ;;; require VS Code extensions
  ;; In an activation.cljs script it can't be guaranteed that a
  ;; particular extension is active, so we can't safely `(:require ..)`
  ;; in the `ns` form. Here's what you can do instead, using Calva
  ;; as the example. To try it for real, copy the example scripts from:
  ;; https://github.com/BetterThanTomorrow/joyride/tree/master/examples
  ;; Then un-ignore the below form and run
  ;;   *Joyride; Run User Script* -> user_activate.cljs
  ;; (Or reload the VS Code window.)
  #_(-> (vscode/extensions.getExtension "betterthantomorrow.calva")
        ;; Force the Calva extension to activate
        (.activate)
        ;; The promise will resolve with the extension's API as the result
        (p/then (fn [_api]
                  (.appendLine (joyride/output-channel) "Calva activated. Requiring dependent namespaces.")
                  ;; In `my-lib` and  `calva-api` the Calva extension
                  ;; is required, which will work fine since now Calva is active.
                  (require '[calva-api])
                  (require '[clojuredocs])
                  ;; Code in your keybindings can now use the `my-lib` and/or
                  ;; `calva-api` namespace(s)
                  ))
        (p/catch (fn [error]
                   (vscode/window.showErrorMessage (str "Requiring Calva failed: " error))))))

#_(when (= (joyride/invoked-script) joyride/*file*)
    (my-main))

;; Feature reminders
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defn get-state []
  (-> (joyride/extension-context)
      .-globalState
      (.get "lastShowedReminder")))

(defn set-state [v]
  (-> (joyride/extension-context)
      .-globalState
      (.update "lastShowedReminder" (.now js/Date))))

(defn days [ts]
  (/ ts 1000 60 60 24))

(defn remind [doc]
  (when (and (= "search-result" (.-languageId doc))
             (or (nil? (get-state))
                 (< 30
                    (days (- (.now js/Date)
                             (get-state))))))
    (vscode/window.showInformationMessage
     "Reminder: you can use \"Apply search editor changes to workspace\"")
    (set-state (.now js/Date))))

(when (= (joyride/invoked-script) joyride/*file*)
  (push-disposable! (.onDidOpenTextDocument vscode/workspace remind)))

(comment
  (clear-disposables!)
  (-> (joyride/extension-context)
      .-globalState
      (.get "lastShowedReminder")
      #_(.update "lastShowedReminder" (- (.now js/Date)
                                         (* 1000 60 60 24 30)))))

;; Wait for gh checks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(comment
  (def git-api
    (-> (vscode/extensions.getExtension "vscode.git")
        .-exports (.getAPI 1)))

  (def branch
    (-> git-api
        (.getRepository uri #_(-> vscode/window.activeTextEditor .-document .-uri))
        .-state .-HEAD .-name))

  (def branch "sc-3594/remove-funding-source-webhook")

  (let [[_ owner repo]
        (-> git-api (.getRepository uri)
            .-state .-remotes
            (as-> $ (filter #(= "origin" (.-name %)) $))
            first .-fetchUrl
            (as-> $ (re-matches #"git@github.com:([^/]+)/([^/]+).git" $)))]
    (def owner owner)
    (def repo repo))

  (def uri (-> vscode/window.visibleTextEditors first .-document .-uri))

  (p/let [res (vscode/authentication.getSession "github" #js ["repo"] #js {"createIfNone" true})]
    (def session res)
    (prn res))

  (defn request [url]
    (p/-> (js/fetch url #js {:headers #js {:Authorization (str "token " (.-accessToken session))}})
          (.json)
          js->clj))

  (p/-> (request (str "https://api.github.com/repos/" owner "/" repo "/commits/" branch "/check-suites"))
        (get-in ["check_suites" 0 "conclusion"])
        prn)

  (-> (js/fetch (str "https://api.github.com/repos/" owner "/" repo "/commits/" branch "/status")
                #js {:headers #js {:Authorization (str "token " (.-accessToken session))}})
      (p/catch (fn [v] (prn "fail" (def res2 v))))
      (p/then (fn [v] (prn "ok") (def res2 v))))
  (-> (.json res2)
      (p/then (fn [v] (prn "json") (def j v)))
      (p/catch (fn [v] (prn "fail") (prn v))))
  (js->clj j)
  ;; repos/:owner/:repo/commits/:branch/status
  {"total_count" 1, "check_suites" [{"url" "https://api.github.com/repos/recbus/recbus/check-suites/47294050288", "after" "8da880dc7548e440d3ba3a24b83bda017544c554", "node_id" "CS_kwDOIz90ls8AAAALAvHv8A", "head_sha" "8da880dc7548e440d3ba3a24b83bda017544c554", "latest_check_runs_count" 10, "repository" {"git_commits_url" "https://api.github.com/repos/recbus/recbus/git/commits{/sha}", "owner" {"received_events_url" "https://api.github.com/users/recbus/received_events", "url" "https://api.github.com/users/recbus", "followers_url" "https://api.github.com/users/recbus/followers", "avatar_url" "https://avatars.githubusercontent.com/u/123026957?v=4", "node_id" "O_kgDOB1U-DQ", "subscriptions_url" "https://api.github.com/users/recbus/subscriptions", "site_admin" false, "id" 123026957, "organizations_url" "https://api.github.com/users/recbus/orgs", "gravatar_id" "", "html_url" "https://github.com/recbus", "starred_url" "https://api.github.com/users/recbus/starred{/owner}{/repo}", "following_url" "https://api.github.com/users/recbus/following{/other_user}", "type" "Organization", "repos_url" "https://api.github.com/users/recbus/repos", "events_url" "https://api.github.com/users/recbus/events{/privacy}", "user_view_type" "public", "login" "recbus", "gists_url" "https://api.github.com/users/recbus/gists{/gist_id}"}, "url" "https://api.github.com/repos/recbus/recbus", "contributors_url" "https://api.github.com/repos/recbus/recbus/contributors", "trees_url" "https://api.github.com/repos/recbus/recbus/git/trees{/sha}", "deployments_url" "https://api.github.com/repos/recbus/recbus/deployments", "full_name" "recbus/recbus", "milestones_url" "https://api.github.com/repos/recbus/recbus/milestones{/number}", "issue_comment_url" "https://api.github.com/repos/recbus/recbus/issues/comments{/number}", "tags_url" "https://api.github.com/repos/recbus/recbus/tags", "node_id" "R_kgDOIz90lg", "blobs_url" "https://api.github.com/repos/recbus/recbus/git/blobs{/sha}", "private" true, "pulls_url" "https://api.github.com/repos/recbus/recbus/pulls{/number}", "keys_url" "https://api.github.com/repos/recbus/recbus/keys{/key_id}", "id" 591361174, "subscription_url" "https://api.github.com/repos/recbus/recbus/subscription", "notifications_url" "https://api.github.com/repos/recbus/recbus/notifications{?since,all,participating}", "collaborators_url" "https://api.github.com/repos/recbus/recbus/collaborators{/collaborator}", "contents_url" "https://api.github.com/repos/recbus/recbus/contents/{+path}", "name" "recbus", "compare_url" "https://api.github.com/repos/recbus/recbus/compare/{base}...{head}", "stargazers_url" "https://api.github.com/repos/recbus/recbus/stargazers", "assignees_url" "https://api.github.com/repos/recbus/recbus/assignees{/user}", "commits_url" "https://api.github.com/repos/recbus/recbus/commits{/sha}", "html_url" "https://github.com/recbus/recbus", "labels_url" "https://api.github.com/repos/recbus/recbus/labels{/name}", "git_refs_url" "https://api.github.com/repos/recbus/recbus/git/refs{/sha}", "issue_events_url" "https://api.github.com/repos/recbus/recbus/issues/events{/number}", "languages_url" "https://api.github.com/repos/recbus/recbus/languages", "downloads_url" "https://api.github.com/repos/recbus/recbus/downloads", "comments_url" "https://api.github.com/repos/recbus/recbus/comments{/number}", "archive_url" "https://api.github.com/repos/recbus/recbus/{archive_format}{/ref}", "events_url" "https://api.github.com/repos/recbus/recbus/events", "hooks_url" "https://api.github.com/repos/recbus/recbus/hooks", "teams_url" "https://api.github.com/repos/recbus/recbus/teams", "fork" false, "subscribers_url" "https://api.github.com/repos/recbus/recbus/subscribers", "releases_url" "https://api.github.com/repos/recbus/recbus/releases{/id}", "branches_url" "https://api.github.com/repos/recbus/recbus/branches{/branch}", "statuses_url" "https://api.github.com/repos/recbus/recbus/statuses/{sha}", "forks_url" "https://api.github.com/repos/recbus/recbus/forks", "issues_url" "https://api.github.com/repos/recbus/recbus/issues{/number}", "description" "The back of the REC Bus", "merges_url" "https://api.github.com/repos/recbus/recbus/merges", "git_tags_url" "https://api.github.com/repos/recbus/recbus/git/tags{/sha}"}, "id" 47294050288, "conclusion" "success", "pull_requests" [{"url" "https://api.github.com/repos/recbus/recbus/pulls/805", "id" 2894359547, "number" 805, "head" {"ref" "sc-3594/remove-funding-source-webhook", "sha" "8da880dc7548e440d3ba3a24b83bda017544c554", "repo" {"id" 591361174, "url" "https://api.github.com/repos/recbus/recbus", "name" "recbus"}}, "base" {"ref" "main", "sha" "3d54a20000dec3de3a55c84b8f0177c55a2d75cc", "repo" {"id" 591361174, "url" "https://api.github.com/repos/recbus/recbus", "name" "recbus"}}}], "check_runs_url" "https://api.github.com/repos/recbus/recbus/check-suites/47294050288/check-runs", "updated_at" "2025-10-09T21:07:03Z", "status" "completed", "app" {"permissions" {"merge_queues" "write", "administration" "read", "repository_projects" "write", "pages" "write", "checks" "write", "security_events" "write", "pull_requests" "write", "attestations" "write", "discussions" "write", "contents" "write", "metadata" "read", "statuses" "write", "issues" "write", "models" "read", "deployments" "write", "vulnerability_alerts" "read", "repository_hooks" "write", "actions" "write", "packages" "write"}, "owner" {"received_events_url" "https://api.github.com/users/github/received_events", "url" "https://api.github.com/users/github", "followers_url" "https://api.github.com/users/github/followers", "avatar_url" "https://avatars.githubusercontent.com/u/9919?v=4", "node_id" "MDEyOk9yZ2FuaXphdGlvbjk5MTk=", "subscriptions_url" "https://api.github.com/users/github/subscriptions", "site_admin" false, "id" 9919, "organizations_url" "https://api.github.com/users/github/orgs", "gravatar_id" "", "html_url" "https://github.com/github", "starred_url" "https://api.github.com/users/github/starred{/owner}{/repo}", "following_url" "https://api.github.com/users/github/following{/other_user}", "type" "Organization", "repos_url" "https://api.github.com/users/github/repos", "events_url" "https://api.github.com/users/github/events{/privacy}", "user_view_type" "public", "login" "github", "gists_url" "https://api.github.com/users/github/gists{/gist_id}"}, "external_url" "https://help.github.com/en/actions", "node_id" "MDM6QXBwMTUzNjg=", "id" 15368, "name" "GitHub Actions", "slug" "github-actions", "updated_at" "2025-03-07T16:35:00Z", "html_url" "https://github.com/apps/github-actions", "events" ["branch_protection_rule" "check_run" "check_suite" "create" "delete" "deployment" "deployment_status" "discussion" "discussion_comment" "fork" "gollum" "issues" "issue_comment" "label" "merge_group" "milestone" "page_build" "project" "project_card" "project_column" "public" "pull_request" "pull_request_review" "pull_request_review_comment" "push" "registry_package" "release" "repository" "repository_dispatch" "status" "watch" "workflow_dispatch" "workflow_run"], "created_at" "2018-07-30T09:30:17Z", "description" "Automate your workflow from idea to production", "client_id" "Iv1.05c79e9ad1f6bdfa"}, "created_at" "2025-10-09T20:34:37Z", "head_commit" {"id" "8da880dc7548e440d3ba3a24b83bda017544c554", "tree_id" "e3448927ca5ad8027b1feb484b196c9878442d5c", "message" "Fix failing tests [sc-3594]", "timestamp" "2025-10-09T20:34:27Z", "author" {"name" "Max Rothman", "email" "max.r.rothman@gmail.com"}, "committer" {"name" "Max Rothman", "email" "max.r.rothman@gmail.com"}}, "runs_rerequestable" false, "before" "ae847073ab903d2f45f9fbc81f34704815fc5a13", "head_branch" "sc-3594/remove-funding-source-webhook", "rerequestable" true}]})