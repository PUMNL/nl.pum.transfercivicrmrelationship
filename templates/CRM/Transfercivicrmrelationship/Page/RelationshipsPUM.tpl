<script type="text/javascript">
{literal}
cj( "#please_wait" ).dialog({ autoOpen: false, height: 400, width: (cj('body').width() < 600 ? cj('body').width() + 'px' : '600px') });

cj('#rel_selectall').click(function(){
  if(cj(this).prop("checked") == true){
    cj('#Relationships_PUM').find(':checkbox').each(function(){jQuery(this).prop('checked', true);});
  } else {
    cj('#Relationships_PUM').find(':checkbox').each(function(){jQuery(this).prop('checked', false);});
  }
});
cj('#transferRelationshipDialog').hide();

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

function update_old_relationship(relation_id){
  var date = new Date().toISOString().slice(0,10);
  let update_rel_success = false;

  CRM.api('Relationship', 'delete', {'id': relation_id},{
    success: function(result) {console.log('Old relation: '+relation_id+' deleted'); console.log(result); update_rel_success = true; },
    error: function(result) {console.log('Error deleting old relation id: '+relation_id); console.log(result); update_rel_success = false; }
  });

  return update_rel_success;
}

function transfer_relationship(relation_id, contact_id_a, to_contact_id, relationship_type_id, case_id, is_active){
  var current_cid = getUrlParameter('cid');
  var date = new Date();
  var dd = (date.getDate() < 10 ? '0' : '') + date.getDate();
  var MM = ((date.getMonth() + 1) < 10 ? '0' : '') + (date.getMonth() + 1);
  var yyyy = date.getFullYear();

  if(!Number.isInteger(relation_id)){
    relation_id = Number(relation_id);
  }

  if(Number.isInteger(relation_id)){
    if(!case_id || case_id.length == 0) {
      CRM.api('Relationship', 'delete', {'id': relation_id},{
        success: function(result) {
          CRM.api('Relationship', 'create', {'sequential': 1, 'contact_id_a': contact_id_a, 'contact_id_b': to_contact_id, 'relationship_type_id': relationship_type_id, 'start_date': yyyy+MM+dd+'000000', 'is_active': is_active}, {
            success: function(data) {
              cj('#Relationships_PUM').load(CRM.url('civicrm/relationshipspum',{snippet: 1, cid: current_cid}));
              window.location.reload();
            },
            error: function(data) {
              console.log('Error creating relationship 1');
              console.log(data);
            }
          });
        },
        error: function(result) {
          console.log('Error deleting relation id: '+relation_id);
          console.log(result);
        }
      });


    } else {
      var date = new Date().toISOString().slice(0,10);

      CRM.api('Relationship', 'delete', {'id': relation_id},{
        success: function(result) {
          CRM.api('Relationship', 'create', {'sequential': 1, 'contact_id_a': contact_id_a, 'contact_id_b': to_contact_id, 'relationship_type_id': relationship_type_id, 'start_date': yyyy+MM+dd+'000000', 'is_active': is_active, 'case_id': case_id, 'check_permissions': 0}, {
            success: function(result2) {
              window.location.reload();
            },
            error: function(result3) {
              console.log('Error creating relationship 2');
              console.log(result3);
            }
          });
        },
        error: function(result) {
          console.log('Error deleting relation id: '+relation_id);
          console.log(result);
        }
      });
    }
  } else {
    CRM.alert(ts('Unable to transfer relationship ID: ')+relation_id, ts('Error transferring relationships'), 'error');
  }
}

cj( function() {
    cj( "#transfer_relationships" ).on( "click", function() {
      dialog = cj('#transferRelationshipDialog').dialog({
        autoOpen: false,
        height: 400,
        width: (cj('body').width() < 600 ? cj('body').width() + 'px' : '600px'),
        modal: true,
        title: ts('Transfer Relationships', {domain: 'nl.pum.transfercivicrmrelationship'}),
        resizable: false,

        open:function() {
          /* set defaults if editing */
          cj("#role_contact").val( "" );
          cj("#role_contact_id").val( null );

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
        },

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
              cj( "#please_wait" ).dialog( "open" );
              cj('#Relationships_PUM').find(':checkbox').each(function(){
                if(this.checked == true && this.id != 'rel_selectall') {
                  var relation_id = '';

                  var contact_id_a = '';
                  var contact_id_b = getUrlParameter('cid');
                  relation_id = this.id.replace('rel_','');

                  if(!Number.isInteger(relation_id)){
                    relation_id = Number(relation_id);
                  }
                  if(Number.isInteger(relation_id)){
                    CRM.api('Relationship', 'getsingle', {'sequential': 1, 'id': Number(relation_id)},{
                      success: function(data) {
                        if(data.contact_id_a != '' && data.contact_id_a != null) {
                          if(data.contact_id_b != '' && data.relationship_type_id != ''){
                            transfer_relationship(data.id, data.contact_id_a, cj('#role_contact_id').val(), data.relationship_type_id, data.case_id, data.is_active);
                          }
                        }
                      }
                    });
                  }
                }
              });
              dialog.dialog('close');
            }
          }
        },
      });

      dialog.dialog('open');
    });

    cj('#relationship-types').change(function(){
      var current_cid = getUrlParameter('cid');
      cj('#Relationships_PUM').empty();
      cj('#Relationships_PUM').load(CRM.url('civicrm/relationshipspum',{snippet: 1, cid: current_cid, relationship_type: cj(this).val()}));
    });
});
{/literal}
</script>

<div id="please_wait" title="Please wait"><p>Relationships are being transferred. Please wait until page is refreshed.</p> <img src="{$extensionsURL}nl.pum.transfercivicrmrelationship/images/icon-loading.gif" width="64px" height="64px" /></div>

<div id="transferRelationshipDialog" title="Transfer Relationships">
  <p class="info">To which contact do you want to transfer these relationships?</p>
  <input type="text" id="role_contact" />
  <input type="hidden" id="role_contact_id" value="" />
</div>

<div class="crm-content-block crm-block">
  <div class="action-link">
    <a accesskey="N" href="/civicrm/contact/view/rel?cid={$clientId}&amp;action=add&amp;reset=1" class="button"><span><div class="icon add-icon"></div>Add Relationship</span></a>
    {if $canTransferRelationship eq 1}<a accesskey="N" href="#" class="button" id="transfer_relationships"><span><div class="icon add-icon"></div>Transfer Relationship</span></a>{/if}
    Filter:
    <select id="relationship-types" style="height: 24px;">
      <option value="all">All relationship types</option>
      {foreach from=$relationshipTypes key=rel_id item=rel_type}
        {if $selected_relationship_type eq $rel_id}
        <option value="{$rel_id}" selected>{$rel_type}</option>
        {else}
        <option value="{$rel_id}">{$rel_type}</option>
        {/if}
      {/foreach}
    </select>
  </div>

  <div id="relationship_wrapper" class="dataTables_wrapper">
    {include file="CRM/common/jsortable.tpl" useAjax=0}
    <table id="relationship-table" class="display">
      <thead>
        <tr>
          {if $canTransferRelationship eq 1}<th class="sorting-disabled" rowspan="1" colspan="1"><input type="checkbox" id="rel_selectall" /></th>{else}{/if}
          <th class="sorting-disabled" rowspan="1" colspan="1">Rel ID</th>
          <th class="sorting-disabled" rowspan="1" colspan="1">Type</th>
          <th class="sorting-disabled" rowspan="1" colspan="1">With contact</th>
          <th class="sorting-disabled" rowspan="1" colspan="1">Start date</th>
          <th class="sorting-disabled" rowspan="1" colspan="1">End date</th>
          <th class="sorting-disabled" rowspan="1" colspan="1">City</th>
          <th class="sorting-disabled" rowspan="1" colspan="1">Country</th>
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
          {if $rel.is_active eq 1 and $rel.active_relationship eq 1}
            <tr class={$rowClass}>
              {if $canTransferRelationship eq 1}{if $rel.rel_end eq ''}<td><input type="checkbox" id="rel_{$rel.rel_id}" /></td>{else}<td></td>{/if}{/if}
              <td{if $rel.is_deleted eq 1} class="font-red"{/if}>{$rel.rel_id}</td>
              <td{if $rel.is_deleted eq 1} class="font-red"{/if}>{$rel.rel_type}</td>
              {if $rel.current_contact eq $rel.contact_id_a}
              <td{if $rel.is_deleted eq 1} class="font-red"{/if}><a href="/civicrm/contact/view?reset=1&cid={$rel.contact_id_b}">{$rel.contact_b_name}</a></td>
              {else}
              <td{if $rel.is_deleted eq 1} class="font-red"{/if}><a href="/civicrm/contact/view?reset=1&cid={$rel.contact_id_a}">{$rel.contact_a_name}</a></td>
              {/if}
              <td{if $rel.is_deleted eq 1} class="font-red"{/if}>{$rel.rel_start}</td>
              <td{if $rel.is_deleted eq 1} class="font-red"{/if}>{$rel.rel_end}</td>
              {if $rel.current_contact eq $rel.contact_id_a}
              <td{if $rel.is_deleted eq 1} class="font-red"{/if}>{$rel.relb_city}</td>
              {else}
              <td{if $rel.is_deleted eq 1} class="font-red"{/if}>{$rel.rela_city}</td>
              {/if}
              {if $rel.current_contact eq $rel.contact_id_a}
              <td{if $rel.is_deleted eq 1} class="font-red"{/if}>{$rel.relb_country}</td>
              {else}
              <td{if $rel.is_deleted eq 1} class="font-red"{/if}>{$rel.rela_country}</td>
              {/if}
              {if $rel.current_contact eq $rel.contact_id_a}
              <td{if $rel.is_deleted eq 1} class="font-red"{/if} style="color: grey;"><a href="mailto:{$rel.relb_email}">{$rel.relb_email}</a></td>
              {else}
              <td{if $rel.is_deleted eq 1} class="font-red"{/if} style="color: grey;"><a href="mailto:{$rel.rela_email}">{$rel.rela_email}</a></td>
              {/if}
              {if $rel.current_contact eq $rel.contact_id_a}
              <td{if $rel.is_deleted eq 1} class="font-red"{/if}><a href="tel:{$rel.relb_phone}">{$rel.relb_phone}</a></td>
              {else}
              <td{if $rel.is_deleted eq 1} class="font-red"{/if}><a href="tel:{$rel.rela_phone}">{$rel.rela_phone}</a></td>
              {/if}
              <td{if $rel.is_deleted eq 1} class="font-red"{/if}>{if $rel.case_id}<a href="/civicrm/contact/view/case?reset=1&id={$rel.case_id}&cid={$rel.contact_id_a}&action=view&context=case&selectedChild=case">{$rel.case_id}</a>{/if}</td>
              <td{if $rel.is_deleted eq 1} class="font-red"{/if}>{if $rel.case_id}{$rel.actions} {$rel.moreActions}{/if}</td>
              {if $rel.current_contact eq $rel.contact_id_a}
                <td><a href="/civicrm/contact/view/rel?action=view&reset=1&cid={$rel.current_contact}&id={$rel.rel_id}&rtype=a_b&selectedChild=rel">View</a> | <a href="/civicrm/contact/view/rel?action=update&reset=1&cid={$rel.current_contact}&id={$rel.rel_id}&rtype=a_b">Edit</a> | <a href="/civicrm/contact/view/rel?action=disable&reset=1&cid={$rel.current_contact}&id={$rel.rel_id}&rtype=a_b">Disable</a> | <a href="/civicrm/contact/view/rel?action=delete&reset=1&cid={$rel.current_contact}&id={$rel.rel_id}&rtype=a_b">Delete</a></td>
              {elseif $rel.current_contact eq $rel.contact_id_b}
                <td><a href="/civicrm/contact/view/rel?action=view&reset=1&cid={$rel.current_contact}&id={$rel.rel_id}&rtype=b_a&selectedChild=rel">View</a> | <a href="/civicrm/contact/view/rel?action=update&reset=1&cid={$rel.current_contact}&id={$rel.rel_id}&rtype=b_a">Edit</a> | <a href="/civicrm/contact/view/rel?action=disable&reset=1&cid={$rel.current_contact}&id={$rel.rel_id}&rtype=b_a">Disable</a> | <a href="/civicrm/contact/view/rel?action=delete&reset=1&cid={$rel.current_contact}&id={$rel.rel_id}&rtype=b_a">Delete</a></td>
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
          {if $irel.is_active eq 0 or $irel.active_relationship eq 0}
            <tr class={$rowClass}>
              {if $canTransferRelationship eq 1}<td></td>{else}{/if}
              <td{if $irel.is_deleted eq 1} class="font-red"{/if} style="color: grey;">{$irel.rel_id}</td>
              <td{if $irel.is_deleted eq 1} class="font-red"{/if} style="color: grey;">{$irel.rel_type}</td>
              {if $irel.current_contact eq $irel.contact_id_a}
              <td{if $irel.is_deleted eq 1} class="font-red"{/if}><a href="/civicrm/contact/view?reset=1&cid={$irel.contact_id_b}">{$irel.contact_b_name}</a></td>
              {else}
              <td{if $irel.is_deleted eq 1} class="font-red"{/if}><a href="/civicrm/contact/view?reset=1&cid={$irel.contact_id_a}">{$irel.contact_a_name}</a></td>
              {/if}
              <td{if $irel.is_deleted eq 1} class="font-red"{/if} style="color: grey;">{$irel.rel_start}</td>
              <td{if $irel.is_deleted eq 1} class="font-red"{/if} style="color: grey;">{$irel.rel_end}</td>
              {if $irel.current_contact eq $irel.contact_id_a}
              <td{if $irel.is_deleted eq 1} class="font-red"{/if} style="color: grey;">{$irel.relb_city}</td>
              {else}
              <td{if $irel.is_deleted eq 1} class="font-red"{/if} style="color: grey;">{$irel.rela_city}</td>
              {/if}
              {if $irel.current_contact eq $irel.contact_id_a}
              <td{if $irel.is_deleted eq 1} class="font-red"{/if} style="color: grey;">{$irel.relb_country}</td>
              {else}
              <td{if $irel.is_deleted eq 1} class="font-red"{/if} style="color: grey;">{$irel.rela_country}</td>
              {/if}
              {if $irel.current_contact eq $irel.contact_id_a}
              <td{if $irel.is_deleted eq 1} class="font-red"{/if} style="color: grey;"><a href="mailto:{$irel.relb_email}">{$irel.relb_email}</a></td>
              {else}
              <td{if $irel.is_deleted eq 1} class="font-red"{/if} style="color: grey;"><a href="mailto:{$irel.rela_email}">{$irel.rela_email}</a></td>
              {/if}
              {if $irel.current_contact eq $irel.contact_id_a}
              <td{if $irel.is_deleted eq 1} class="font-red"{/if} style="color: grey;"><a href="tel:{$irel.relb_phone}">{$irel.relb_phone}</a></td>
              {else}
              <td{if $irel.is_deleted eq 1} class="font-red"{/if} style="color: grey;"><a href="tel:{$irel.rela_phone}">{$irel.rela_phone}</a></td>
              {/if}
              <td{if $irel.is_deleted eq 1} class="font-red"{/if} style="color: grey;">{if empty($irel.case_id)}{else}<a href="/civicrm/contact/view/case?reset=1&id={$irel.case_id}&cid={$irel.contact_id_a}&action=view&context=case&selectedChild=case">{$irel.case_id}</a>{/if}</td>
              <td{if $irel.is_deleted eq 1} class="font-red"{/if} style="color: grey;">{$irel.actions} {$irel.moreActions}</td>
              </td>
              {if $irel.current_contact eq $irel.contact_id_a}
                <td><a href="/civicrm/contact/view/rel?action=view&reset=1&cid={$irel.current_contact}&id={$irel.rel_id}&rtype=a_b&selectedChild=rel">View</a> | <a href="/civicrm/contact/view/rel?action=update&reset=1&cid={$irel.current_contact}&id={$irel.rel_id}&rtype=a_b">Edit</a> | <a href="/civicrm/contact/view/rel?action=enable&reset=1&cid={$irel.current_contact}&id={$irel.rel_id}&rtype=a_b">Enable</a></td>
              {elseif $irel.current_contact eq $irel.contact_id_b}
                <td><a href="/civicrm/contact/view/rel?action=view&reset=1&cid={$irel.current_contact}&id={$irel.rel_id}&rtype=b_a&selectedChild=rel">View</a> | <a href="/civicrm/contact/view/rel?action=update&reset=1&cid={$irel.current_contact}&id={$irel.rel_id}&rtype=b_a">Edit</a> | <a href="/civicrm/contact/view/rel?action=enable&reset=1&cid={$irel.current_contact}&id={$irel.rel_id}&rtype=b_a">Enable</a></td>
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
              {$pager->_response.titleBottom}&nbsp;
              <input type="submit" onclick="cj('#Relationships_PUM').load('/index.php?cid={$clientId}&q=civicrm/relationshipspum&force=1&crmPID='+cj('input[name=&quot;crmPID_B&quot;]').val()+'&snippet=1');" class="form-submit" style="cursor:pointer;" value="Go">
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