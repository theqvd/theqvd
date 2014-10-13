<div class="welcome-message">
    <span class="welcome" data-i18n="Welcome to QVD's Web Administration Tool"></span>
</div>

<div class="home-wrapper">
    <div class="home-row">
        <% if (Wat.C.checkACL('vm_see')) { %>
        <div class="home-cell">
            <div class="home-title" data-i18n>Running virtual machines</div>
            <div class="home-percent-wrapper">
                <div class="js-running-vms-percent home-title home-percent js-home-percent"></div>
                <div id="running-vms" class="pie-chart js-pie-chart" data-target="vms" width="200px" height="200px"></div>
            </div>
            <a href="#/vms">
                <div class="js-running-vms-data home-title"></div>
            </a>
        </div>
        <% } %>


        <div class="home-cell">
            <div class="home-title" data-i18n>Summary</div>
            <table class="summary-table">
                <% if (Wat.C.checkACL('user_see')) { %>
                <tr>
                    <td class="max-1-icons">
                        <i class="<%= CLASS_ICON_USERS %>"></i>
                    </td>                    
                    <td>
                        <a href="#/users" data-i18n="Users">
                            <%= i18n.t('Users') %>
                        </a>
                    </td>
                    <td>
                        <span class="summary-data js-summary-users"><%= stats.User.total %></span>
                    </td>
                </tr>
                <% } if (Wat.C.checkACL('vm_see')) { %>
                <tr>    
                    <td class="max-1-icons">
                        <i class="<%= CLASS_ICON_VMS %>"></i>
                    </td>        
                    <td>
                        <a href="#/vms" data-i18n="Virtual machines">
                            <%= i18n.t('Virtual machines') %>
                        </a>
                    </td>
                    <td>
                        <span class="summary-data js-summary-vms"><%= stats.VM.total %></span>
                    </td>
                </tr>
                <% } if (Wat.C.checkACL('host_see')) { %>
                <tr>
                    <td class="max-1-icons">
                        <i class="<%= CLASS_ICON_HOSTS %>"></i>
                    </td>       
                    <td>
                        <a href="#/hosts" data-i18n="Nodes">
                            <%= i18n.t('Nodes') %>
                        </a>
                    </td>
                    <td>
                        <span class="summary-data js-summary-hosts"><%= stats.Host.total %></span>
                    </td>
                </tr>
                <% } if (Wat.C.checkACL('osf_see')) { %>
                <tr>
                    <td class="max-1-icons">
                        <i class="<%= CLASS_ICON_OSFS %>"></i>
                    </td>   
                    <td>
                        <a href="#/osfs" data-i18n="OS Flavours">
                            <%= i18n.t('OS Flavours') %>
                        </a>
                    </td>
                    <td>
                        <span class="summary-data js-summary-osfs"><%= stats.OSF.total %></span>
                    </td>
                </tr>
                <% } if (Wat.C.checkACL('di_see')) { %>
                <tr>
                    <td class="max-1-icons">
                        <i class="<%= CLASS_ICON_DIS %>"></i>
                    </td>                
                    <td>
                        <a href="#/dis" data-i18n="Disk images">
                            <%= i18n.t('Disk images') %>
                        </a>
                    </td>
                    <td>
                        <span class="summary-data js-summary-dis"><%= stats.DI.total %></span>
                    </td>
                </tr>
                <% } %>
            </table>
            <table id="summary">
            </table>
        </div>
        
        <% if (Wat.C.checkACL('host_see')) { %>
        <div class="home-cell">
            <div class="home-title" data-i18n>Running nodes</div>
            <div class="home-percent-wrapper">
                <div class="js-running-hosts-percent home-title home-percent js-home-percent"></div>
                <div id="running-hosts" class="pie-chart js-pie-chart" data-target="hosts" width="200px" height="200px"></div>
            </div>
            <a href="#/hosts">
                <div class="js-running-hosts-data home-title"></div>
            </a>
        </div>
        <% } %>
    </div>
</div>
<div class="home-wrapper">
    <div class="home-row">
        <% if (Wat.C.checkACL('vm_see')) { %>
        <div class="home-cell">
            <div class="home-title" data-i18n>VMs close to expire</div>
            <%
                if (stats.VM.expiration.length == 0) {
            %>
                <div class="no-elements" data-18n>There are not VMS close to expire</div>
            <%
                }
                else {
            %>
                    <table class="summary-table">
                    <% 
                        $.each(stats.VM.expiration, function (iExp, exp) {
                            var priorityClass = '';
                            var remainingTime = '';
                            var remainingTimeAttr = '';
                            if (exp.remaining_time.days < 1) {
                                priorityClass = 'error';
                                remainingTime = exp.remaining_time.hours + ':' + exp.remaining_time.minutes + ':' + exp.remaining_time.seconds;
                            }
                            else if(exp.remaining_time.days < 7) {
                                priorityClass = 'warning';
                                remainingTimeAttr = 'data-days="' + exp.remaining_time.days + '"';
                            }
                            else {
                                priorityClass = 'ok';
                                remainingTimeAttr = 'data-days="+7"';
                            }                    
                            %>
                            <tr>
                                <td class="max-1-icons">
                                    <i class="fa fa-warning <%= priorityClass %>"></i>
                                </td>                    
                                <td>
                                    <a href="#/vm/<%= exp.id %>">
                                        <%= exp.name %>
                                    </a>
                                </td>
                                <td>
                                    <span class="summary-data js-summary-users" <%= remainingTimeAttr %>><%= remainingTime %></span>
                                </td>
                            </tr>
                            <%
                        }); 
                    %>
                    </table>
                    
                <%
                    }
                %>
        </div>
        <% } if (Wat.C.checkACL('host_see')) { %>
        <div class="home-cell">
            <div class="home-title" data-i18n>Nodes with most running VMs</div>
            <div id="hosts-more-vms" class="bar-chart js-bar-chart" style="width:95%;height:200px;"></div>
        </div>
        <% } %>
        <div class="home-cell">
            <div class="home-title" data-i18n>Blocked elements</div>
            <table class="summary-table">
                <% if (Wat.C.checkACL('user_see')) { %>
                <tr>
                    <td class="max-1-icons">
                        <i class="<%= CLASS_ICON_USERS %>"></i>
                    </td>                    
                    <td>
                        <a href="#/users" data-i18n="Users">
                            <%= i18n.t('Users') %>
                        </a>
                    </td>
                    <td>
                        <span class="summary-data js-summary-blocked-users"><%= stats.User.blocked %></span>
                    </td>
                </tr>
                <% } if (Wat.C.checkACL('vm_see')) { %>
                <tr>    
                    <td class="max-1-icons">
                        <i class="<%= CLASS_ICON_VMS %>"></i>
                    </td>        
                    <td>
                        <a href="#/vms" data-i18n="Virtual machines">
                            <%= i18n.t('Virtual machines') %>
                        </a>
                    </td>
                    <td>
                        <span class="summary-data js-summary-blocked-vms"><%= stats.VM.blocked %></span>
                    </td>
                </tr>
                <% } if (Wat.C.checkACL('host_see')) { %>
                <tr>
                    <td class="max-1-icons">
                        <i class="<%= CLASS_ICON_HOSTS %>"></i>
                    </td>       
                    <td>
                        <a href="#/hosts" data-i18n="Nodes">
                            <%= i18n.t('Nodes') %>
                        </a>
                    </td>
                    <td>
                        <span class="summary-data js-summary-blocked-hosts"><%= stats.Host.blocked %></span>
                    </td>
                </tr>
                <% } if (Wat.C.checkACL('di_see')) { %>
                <tr>
                    <td class="max-1-icons">
                        <i class="<%= CLASS_ICON_DIS %>"></i>
                    </td>                
                    <td>
                        <a href="#/dis" data-i18n="Disk images">
                            <%= i18n.t('Disk images') %>
                        </a>
                    </td>
                    <td>
                        <span class="summary-data js-summary-blocked-dis"><%= stats.DI.blocked %></span>
                    </td>
                </tr>
                <% } %>
            </table>
        </div>
    </div>
</div>