trigger LeadTrigger on Lead (before insert, before update) {
    new LeadTriggerHandler().beforeInsertUpdate(Trigger.new);
}