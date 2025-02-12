(ns expand
  (:require ["vscode" :as vscode]
            [joyride.core :as joyride]
            [promesa.core :as p]))

;; Wrap parens
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defn spy [x] (js/console.log (clj->js x)) x)

(defn poscls->clj [pos]
  {:line (.-line pos), :chr (.-character pos)})

(defn rangecls->clj [rng]
  {:start (poscls->clj (.-start rng))
   :end (poscls->clj (.-end rng))
   :active (poscls->clj (.-active rng))})

(defn ->poscls [pos]
  (vscode/Position. (:line pos) (:chr pos)))

(defn ->rangecls [rng]
  (vscode/Range. (->poscls (:start rng)) (->poscls (:end rng))))

(defn cur-selection []
  (rangecls->clj (.-selection vscode/window.activeTextEditor)))

(defn char-at-cursor []
  (.getText (-> vscode/window.activeTextEditor .-document)
            (-> (cur-selection)
                (update-in [:end :chr] inc)
                ->rangecls)))

(defn edit-p
  {:arglists '([action ^js where & [text]] & edits)}
  [edits]
  (let [editor vscode/window.activeTextEditor]
    (.edit editor
           (fn [^js builder]
             (doseq [[action ^js where text] edits]
               (case action
                 ;; for :insert, where is a Position, for delete, a Range
                 :insert (.insert builder where text)
                 :delete (.delete builder where))))
           #_#js {:undoStopBefore true :undoStopAfter false})
    #_(p/catch (fn [e]
                 (js/console.error e)))))

;; Strategy:
;; - If the character in front of the cursor isn't a parens, add a set of parens matching the
;;   nearest expand-selection range
;; - Otherwise:
;;   - find the matching paren to the one in front of the cursor
;;   - delete both
;;   - highlight everything that was between them
;;   - expand-selection
;;   - surround in parens 

@(if (= "(" (char-at-cursor))
   (let [left-paren (:active (cur-selection))]
     (p/do
       (vscode/commands.executeCommand "editor.action.jumpToBracket")
       (let [right-paren (:active (cur-selection))]
         (p/do
           (edit-p [[:delete (->rangecls {:start left-paren
                                          :end (update left-paren :chr inc)})]
                    [:delete (->rangecls {:start right-paren
                                          :end (update right-paren :chr inc)})]])
           (set! (.-selection vscode/window.activeTextEditor)
                 (vscode/Selection. (->poscls left-paren) 
                                    (->poscls (update right-paren :chr dec))))
           (vscode/commands.executeCommand "editor.action.smartSelect.expand")
           (let [{:keys [start end]} (cur-selection)]
             (p/do
               (edit-p [[:insert (->poscls start) "("]
                        [:insert (->poscls end) ")"]])
               (set! (.-selection vscode/window.activeTextEditor)
                     (vscode/Selection. (->poscls start) (->poscls start)))))))))
   (p/do
       (vscode/commands.executeCommand "editor.action.smartSelect.expand")
       (let [{:keys [start end]} (cur-selection)]
         (p/do
           (edit-p [[:insert (->poscls start) "("]
                    [:insert (->poscls end) ")"]])
           (set! (.-selection vscode/window.activeTextEditor)
                 (vscode/Selection. (->poscls start) (->poscls start)))))))

#_@(-> (edit-p [[:delete (->rangecls {:start {:line 75 :chr 1}
                                    :end   {:line 75 :chr 4}})]]) 
     (p/catch #(prn %)))
#_(set! (.-selection vscode/window.activeTextEditor)
      (vscode/Selection. (->poscls {:line 81 :chr 0}) (->poscls {:line 81 :chr 0})))