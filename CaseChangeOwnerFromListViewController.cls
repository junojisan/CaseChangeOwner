/*
 * ケースビューからの所有者変更ページのコントローラーです
 */
public class CaseChangeOwnerFromListViewController {
    // スタンダードセットコントローラー
    private ApexPages.StandardSetController controller;
    // 画面表示時のケースを保持するマップ（Key：ケースID、Value：ケース）
    private Map<Id, Case> oldCaseMap = new Map<Id, Case>();
    // ビューでケースが選択されているかのフラグ
    public Boolean isSelected{get; set;}
    // 所有者変更対象のケース番号
    public String caseNumbers {get; set;}

    /*
     * コンストラクター
     * @param ApexPages.StandardSetController
     */
    public CaseChangeOwnerFromListViewController(ApexPages.StandardSetController controller) {
        this.controller = controller;
        Set<Id> caseIds = new Set<Id>();
        for(Case c : (List<Case>)controller.getSelected()){
            caseIds.add(c.Id);
        }
        
        isSelected = true;
        if(caseIds.isEmpty()){
            isSelected = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '所有者変更を行うケースが選択されていません。'));
            return;
        }
        
        caseNumbers = '';
        for(Case c : [Select CaseNumber, OwnerId From Case Where Id In :caseIds]){
            oldCaseMap.put(c.Id, c);
            caseNumbers += c.CaseNumber + ';';
        }
    }

    /*
     * 保存処理
     * @param
     * @return PageReference
     */
    public PageReference save() {
        Set<Id> caseIds = new Set<Id>();
        for(Case c : (List<Case>)controller.getSelected()){
            caseIds.add(c.Id);
        }
        
        Boolean isConflictOwner = false;
        for(Case c : [Select OwnerId From Case Where Id In :caseIds]){
        Case oldCase = oldCaseMap.get(c.Id);
            if(c.OwnerId != oldCase.OwnerId){
                isConflictOwner = true;
                break;
            }
        }
        
        if(isConflictOwner){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ケース内容が変更されたため、所有者変更ができませんでした。'));
            return null;
        }
        return controller.save();
    }
}