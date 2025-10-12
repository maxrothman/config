;; This is built-in in later versions of vscode
(comment
  (ns task-complete-notification
    (:require ["vscode" :as vscode]
              ["child_process" :as process]
              [joyride.core :as joyride]))

  ;; Can't detect success or failure, use onDidEndTaskProcess instead?
  ;; Refs
  ;; - https://code.visualstudio.com/api/references/vscode-api#Task
  ;; - https://github.com/charlie-rbchd/vscode-task-notifier/blob/master/src/extension.ts
  (defn notify [e]
    (prn "here")
    (process/exec
     (str "osascript -e '"
          "display notification "
          "\"" (.. e -execution -task -name) "\" "
          "with title \"Task Done\" sound name \"Ping\""
          "'")
     (fn [err stdout stderr]
       (prn err)
       (prn stdout)
       (prn stderr))))


  @(def disposable
     (-> vscode/tasks
         (.onDidEndTask notify)))



  (.dispose disposable)

  (-> (joyride/extension-context)
      .-subscriptions
      (.push disposable))
  )