<script type="text/javascript">
{literal}
cj('#rel_selectall').click(function(){
  if(cj(this).prop("checked") == true){
    cj('#Relationships_PUM').find(':checkbox').each(function(){jQuery(this).prop('checked', true);});
  } else {
    cj('#Relationships_PUM').find(':checkbox').each(function(){jQuery(this).prop('checked', false);});
  }
});

function getUrlParameter(sParam) {
    var sPageURL = window.location.search.substring(1),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true : decodeURIComponent(sParameterName[1]);
        }
    }
}

function transfer_relationship(relation_id, contact_id_a, to_contact_id, relationship_type_id, case_id, is_active){
  var current_cid = getUrlParameter('cid');
  var date = new Date();
  var dd = (date.getDate() < 10 ? '0' : '') + date.getDate();
  var MM = ((date.getMonth() + 1) < 10 ? '0' : '') + (date.getMonth() + 1);
  var yyyy = date.getFullYear();

  if(!case_id || case_id.length == 0) {
    update_old_relationship(relation_id,contact_id_a);

    CRM.api('Relationship', 'create', {'sequential': 1, 'contact_id_a': contact_id_a, 'contact_id_b': to_contact_id, 'relationship_type_id': relationship_type_id, 'start_date': yyyy+MM+dd+'000000', 'is_active': is_active}, {
      success: function(data) {
        cj('#Relationships_PUM').load(CRM.url('civicrm/relationshipspum',{snippet: 1, cid: current_cid}));

        CRM.api('Relationship', 'get', {'sequential': 1, 'contact_id_b': current_cid, 'is_active': 1, 'rowCount': 0},{
          success: function(data2) {
            window.location.reload();
          }
        });
      },
      error: function(data) {

      }
    });
  } else {
    update_old_relationship(relation_id,contact_id_a);

    CRM.api('Relationship', 'create', {'sequential': 1, 'contact_id_a': contact_id_a, 'contact_id_b': to_contact_id, 'relationship_type_id': relationship_type_id, 'start_date': yyyy+MM+dd+'000000', 'is_active': is_active, 'case_id': case_id}, {
      success: function(data3) {
        window.location.reload();

      },
      error: function(data) {

      }
    });
  }
}

function update_old_relationship(relation_id, contact_id_a){
  var date = new Date().toISOString().slice(0,10);

  CRM.api('Relationship', 'delete', {'id': relation_id},{
    success: function(data) { },
    error: function(data) { }
  });
}

cj( function() {

  dialog = cj('#transferRelationshipDialog').dialog({
      autoOpen: false,
      height: 400,
      width: (cj('body').width() < 600 ? cj('body').width() + 'px' : '600px'),
      modal: true,
      title: ts('Transfer Relationships', {domain: 'nl.pum.transfercivicrmrelationship'}),
      resizable: false,

      buttons: {
        'cancel': {
          text: ts('Cancel', {domain: 'nl.pum.transfercivicrmrelationship'}),
          click: function() {
            dialog.dialog('close');
          }
        },
        'continue': {
          text: ts('Continue', {domain: 'nl.pum.transfercivicrmrelationship'}),
          click: function() {
            cj('#Relationships_PUM').find(':checkbox').each(function(){
              if(this.checked == true) {
                var relation_id = '';

                var contact_id_a = '';
                var contact_id_b = getUrlParameter('cid');
                relation_id = this.id.replace('rel_','');

                CRM.api('Relationship', 'getsingle', {'sequential': 1, 'id': relation_id},{
                  success: function(data) {
                    if(data.contact_id_a != '' && data.contact_id_a != null) {
                      if(data.contact_id_b != '' && data.relationship_type_id != ''){
                        var date = new Date();
                        var dd = (date.getDate() < 10 ? '0' : '') + date.getDate();
                        var MM = ((date.getMonth() + 1) < 10 ? '0' : '') + (date.getMonth() + 1);
                        var yyyy = date.getFullYear();

                        transfer_relationship(data.id, data.contact_id_a, cj('#role_contact_id').val(), data.relationship_type_id, data.case_id, data.is_active);
                      }
                    }
                  }
                });
              }
            });
            dialog.dialog('close');
          }
        }
      }
    });
    var contactUrl = {/literal}"{crmURL p='civicrm/ajax/rest' q='className=CRM_Contact_Page_AJAX&fnName=getContactList&json=1&context=caseview' h=0 }"{literal};

      cj("#role_contact").autocomplete( contactUrl, {
        width: 500,
        selectFirst: false,
        matchContains: true
      });

      cj("#role_contact").focus();
      cj("#role_contact").result(function(event, data, formatted) {
        cj("input[id=role_contact_id]").val(data[1]);
      });
    cj( "#transfer_relationships" ).on( "click", function() {
      dialog.dialog( "open" );
    });



});
{/literal}
</script>

<div id="transferRelationshipDialog" title="Transfer Relationships">
  <p class="info">To which contact do you want to transfer these relationships?</p>
  <input type="text" id="role_contact" />
  <input type="hidden" id="role_contact_id" value="" />
</div>

<div class="crm-content-block crm-block">
  <div class="action-link">
    <a accesskey="N" href="/civicrm/contact/view/rel?cid={$clientId}&amp;action=add&amp;reset=1" class="button"><span><div class="icon add-icon"></div>Add Relationship</span></a>
    {if $isAdmin eq 1}<a accesskey="N" href="#" class="button" id="transfer_relationships"><span><div class="icon add-icon"></div>Transfer Relationship</span></a>{/if}
  </div>
  <div id="relationship_wrapper" class="dataTables_wrapper">
    <table id="relationship-table" class="display">
      <thead>
        <tr>
          {if $isAdmin eq 1}<th class="sorting-disabled" rowspan="1" colspan="1"><input type="checkbox" id="rel_selectall" /></th>{/if}
          <th class="sorting-disabled" rowspan="1" colspan="1">Rel ID</th>
          <th class="sorting-disabled" rowspan="1" colspan="1">Type</th>
          <th class="sorting-disabled" rowspan="1" colspan="1">With contact</th>
          <th class="sorting-disabled" rowspan="1" colspan="1">Start date</th>
          <th class="sorting-disabled" rowspan="1" colspan="1">End date</th>
          <th class="sorting-disabled" rowspan="1" colspan="1">City</th>
          <th class="sorting-disabled" rowspan="1" colspan="1">E-mail</th>
          <th class="sorting-disabled" rowspan="1" colspan="1">Phone</th>
          <th class="sorting-disabled" rowspan="1" colspan="1">Case ID</th>
          <th class="sorting-disabled" rowspan="1" colspan="1">Case Actions</th>
          <th class="sorting-disabled" rowspan="1" colspan="1">Relationship Actions</th>
        </tr>
      </thead>
      <tbody>
        {assign var="rowClass" value="odd-row"}
        {foreach from=$relationships item=rel}
          {if $rel.is_active eq 1}
            <tr class={$rowClass}>
              {if $isAdmin eq 1}<td><input type="checkbox" id="rel_{$rel.rel_id}" /></td>{/if}
              <td{if $rel.is_deleted eq 1} class="font-red"{/if}>{$rel.rel_id}</td>
              <td{if $rel.is_deleted eq 1} class="font-red"{/if}>{$rel.rel_type}</td>
              {if $rel.current_contact eq $rel.contact_id_a}
              <td{if $rel.is_deleted eq 1} class="font-red"{/if}>{$rel.contact_b_name}</td>
              {else}
              <td{if $rel.is_deleted eq 1} class="font-red"{/if}>{$rel.contact_a_name}</td>
              {/if}
              <td{if $rel.is_deleted eq 1} class="font-red"{/if}>{$rel.rel_start}</td>
              <td{if $rel.is_deleted eq 1} class="font-red"{/if}>{$rel.rel_end}</td>
              <td{if $rel.is_deleted eq 1} class="font-red"{/if}>{$rel.rel_city}</td>
              <td{if $rel.is_deleted eq 1} class="font-red"{/if}>{$rel.rel_email}</td>
              <td{if $rel.is_deleted eq 1} class="font-red"{/if}>{$rel.rel_phone}</td>
              <td{if $rel.is_deleted eq 1} class="font-red"{/if}>{if $rel.case_id}<a href="/civicrm/contact/view/case?reset=1&id={$rel.case_id}&cid={$rel.contact_id_a}&action=view&context=case&selectedChild=case">{$rel.case_id}</a>{/if}</td>
              <td{if $rel.is_deleted eq 1} class="font-red"{/if}>{if $rel.case_id}{$rel.actions} {$rel.moreActions}{/if}</td>
              {if $rel.current_contact eq $rel.contact_id_a}
                <td><a href="/civicrm/contact/view/rel?action=view&reset=1&cid={$rel.current_contact}&id={$rel.rel_id}&rtype=a_b&selectedChild=rel">View</a> | <a href="/civicrm/contact/view/rel?action=update&reset=1&cid={$rel.current_contact}&id={$rel.rel_id}&rtype=a_b">Edit</a></td>
              {elseif $rel.current_contact eq $rel.contact_id_b}
                <td><a href="/civicrm/contact/view/rel?action=view&reset=1&cid={$rel.current_contact}&id={$rel.rel_id}&rtype=b_a&selectedChild=rel">View</a> | <a href="/civicrm/contact/view/rel?action=update&reset=1&cid={$rel.current_contact}&id={$rel.rel_id}&rtype=b_a">Edit</a></td>
              {/if}
            </tr>
          {/if}

          {if $rowClass eq "odd-row"}
            {assign var="rowClass" value="even-row"}
          {else}
            {assign var="rowClass" value="odd-row"}
          {/if}
        {/foreach}

        {foreach from=$relationships item=irel name=rel}
          {if $irel.is_active eq 0}
            <tr class={$rowClass}>
              {if $isAdmin eq 1}<td></td>{/if}
              <td{if $irel.is_deleted eq 1} class="font-red"{/if} style="color: grey;">{$irel.rel_id}</td>
              <td{if $irel.is_deleted eq 1} class="font-red"{/if} style="color: grey;">{$irel.rel_type}</td>
              {if $irel.current_contact eq $irel.contact_id_a}
              <td{if $irel.is_deleted eq 1} class="font-red"{/if}>{$irel.contact_b_name}</td>
              {else}
              <td{if $irel.is_deleted eq 1} class="font-red"{/if}>{$irel.contact_a_name}</td>
              {/if}
              <td{if $irel.is_deleted eq 1} class="font-red"{/if} style="color: grey;">{$irel.rel_start}</td>
              <td{if $irel.is_deleted eq 1} class="font-red"{/if} style="color: grey;">{$irel.rel_end}</td>
              <td{if $irel.is_deleted eq 1} class="font-red"{/if} style="color: grey;">{$irel.rel_city}</td>
              <td{if $irel.is_deleted eq 1} class="font-red"{/if} style="color: grey;">{$irel.rel_email}</td>
              <td{if $irel.is_deleted eq 1} class="font-red"{/if} style="color: grey;">{$irel.rel_phone}</td>
              <td{if $irel.is_deleted eq 1} class="font-red"{/if} style="color: grey;">{if empty($irel.case_id)}{else}<a href="/civicrm/contact/view/case?reset=1&id={$irel.case_id}&cid={$irel.contact_id_a}&action=view&context=case&selectedChild=case">{$irel.case_id}</a>{/if}</td>
              <td{if $irel.is_deleted eq 1} class="font-red"{/if} style="color: grey;">{$irel.actions} {$irel.moreActions}</td>
              </td>
              {if $irel.current_contact eq $irel.contact_id_a}
                <td><a href="/civicrm/contact/view/rel?action=view&reset=1&cid={$irel.current_contact}&id={$irel.rel_id}&rtype=a_b&selectedChild=rel">View</a> | <a href="/civicrm/contact/view/rel?action=update&reset=1&cid={$irel.current_contact}&id={$irel.rel_id}&rtype=a_b">Edit</a></td>
              {elseif $irel.current_contact eq $irel.contact_id_b}
                <td><a href="/civicrm/contact/view/rel?action=view&reset=1&cid={$irel.current_contact}&id={$irel.rel_id}&rtype=b_a&selectedChild=rel">View</a> | <a href="/civicrm/contact/view/rel?action=update&reset=1&cid={$irel.current_contact}&id={$irel.rel_id}&rtype=b_a">Edit</a></td>
              {/if}
            </tr>
          {/if}
          {if $rowClass eq "odd-row"}
            {assign var="rowClass" value="even-row"}
          {else}
            {assign var="rowClass" value="odd-row"}
          {/if}
        {/foreach}
      </tbody>
    </table>
  </div>

  {if $pager and $pager->_response}
    {if $pager->_response.numPages > 1}
        <div class="crm-pager">
          {if ! isset($noForm) || ! $noForm}
            <span class="element-right">
            {if $location eq 'top'}
              {$pager->_response.titleTop}&nbsp;<input class="form-submit" name="{$pager->_response.buttonTop}" value="{ts}Go{/ts}" type="submit"/>
            {else}
              {$pager->_response.titleBottom}&nbsp;<input class="form-submit" name="{$pager->_response.buttonBottom}" value="{ts}Go{/ts}" type="submit"/>
            {/if}
            </span>
          {/if}
          <span style="margin-left:10px;">
          {if !empty($pager->linkTagsRaw.first.url)}
          <input type="submit" onclick="cj('#Relationships_PUM').load('{$pager->linkTagsRaw.first.url}&snippet=1')" class="form-submit" style="cursor:pointer;" value="<< First" />&nbsp;
          {/if}
          {if !empty($pager->linkTagsRaw.prev.url)}
          <input type="submit" onclick="cj('#Relationships_PUM').load('{$pager->linkTagsRaw.prev.url}&snippet=1')" class="form-submit" style="cursor:pointer;" value="< Previous" />&nbsp;
          {/if}
          {if !empty($pager->linkTagsRaw.next.url)}
          <input type="submit" onclick="cj('#Relationships_PUM').load('{$pager->linkTagsRaw.next.url}&snippet=1')" class="form-submit" style="cursor:pointer;" value="Next >" />&nbsp;
          {/if}
          {if !empty($pager->linkTagsRaw.last.url)}
          <input type="submit" onclick="cj('#Relationships_PUM').load('{$pager->linkTagsRaw.last.url}&snippet=1')" class="form-submit" style="cursor:pointer;" value="Last >>" />&nbsp;
          {/if}
          {$pager->_response.status}
          </span>

        </div>
    {/if}

    {* Controller for 'Rows Per Page' *}
    {if $location eq 'bottom' and $pager->_totalItems > 25}
     <div class="form-item float-right">
           <label>{ts}Rows per page:{/ts}</label> &nbsp;
           {$pager->_response.twentyfive}&nbsp; | &nbsp;
           {$pager->_response.fifty}&nbsp; | &nbsp;
           {$pager->_response.onehundred}&nbsp;
     </div>
     <div class="clear"></div>
    {/if}

  {/if}
</div>