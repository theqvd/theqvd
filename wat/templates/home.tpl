<div class="welcome-message">
    <span class="welcome" data-i18n="Welcome to QVD's Web Administration Tool"></span>
</div>

<div class="home-wrapper">
    <div class="home-row">
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

        <div class="home-cell">
            <div class="home-title" data-i18n>Summary</div>
            <table class="summary-table">
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
                        <span class="summary-data js-summary-users">58</span>
                    </td>
                </tr>
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
                        <span class="summary-data js-summary-vms">31</span>
                    </td>
                </tr>
                <tr>
                    <td class="max-1-icons">
                        <i class="<%= CLASS_ICON_NODES %>"></i>
                    </td>       
                    <td>
                        <a href="#/hosts" data-i18n="Nodes">
                            <%= i18n.t('Nodes') %>
                        </a>
                    </td>
                    <td>
                        <span class="summary-data js-summary-nodes">3</span>
                    </td>
                </tr>
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
                        <span class="summary-data js-summary-osfs">3</span>
                    </td>
                </tr>
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
                        <span class="summary-data js-summary-dis">14</span>
                    </td>
                </tr>
            </table>
            <table id="summary">
            </table>
        </div>
        
        <div class="home-cell">
            <div class="home-title" data-i18n>Running nodes</div>
            <div class="home-percent-wrapper">
                <div class="js-running-nodes-percent home-title home-percent js-home-percent"></div>
                <div id="running-nodes" class="pie-chart js-pie-chart" data-target="hosts" width="200px" height="200px"></div>
            </div>
            <a href="#/hosts">
                <div class="js-running-nodes-data home-title"></div>
            </a>
        </div>
    </div>
</div>
<div class="home-wrapper">
    <div class="home-row">
        <div class="home-cell">
            <div class="home-title" data-i18n>VMs close to expire</div>
            <table class="summary-table">
                <tr>
                    <td class="max-1-icons">
                        <i class="fa fa-warning error"></i>
                    </td>                    
                    <td>
                        Virtual machine 1
                    </td>
                    <td>
                        <span class="summary-data js-summary-users">1 days</span>
                    </td>
                </tr>
                <tr>    
                    <td class="max-1-icons">
                        <i class="fa fa-warning warning"></i>
                    </td>        
                    <td>
                        Virtual machine 34
                    </td>
                    <td>
                        <span class="summary-data js-summary-vms">2 days</span>
                    </td>
                </tr>
                <tr>
                    <td class="max-1-icons">
                        <i class="fa fa-warning error"></i>
                    </td>       
                    <td>
                        Virtual machine 2
                    </td>
                    <td>
                        <span class="summary-data js-summary-nodes">5 days</span>
                    </td>
                </tr>
                <tr>
                    <td class="max-1-icons">
                        <i class="fa fa-warning error"></i>
                    </td>                
                    <td>
                        Virtual machine 13
                    </td>
                    <td>
                        <span class="summary-data js-summary-dis">8 days</span>
                    </td>
                </tr>
            </table>
        </div>
        <div class="home-cell">
            <div class="home-title" data-i18n>Nodes with more running VMs</div>
            <div id="nodes-more-vms" class="bar-chart js-bar-chart" style="width:95%;height:200px;"></div>
        </div>
        <div class="home-cell">
            <div class="home-title" data-i18n>Blocked elements</div>
            <table class="summary-table">
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
                        <span class="summary-data js-summary-users">0</span>
                    </td>
                </tr>
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
                        <span class="summary-data js-summary-vms">0</span>
                    </td>
                </tr>
                <tr>
                    <td class="max-1-icons">
                        <i class="<%= CLASS_ICON_NODES %>"></i>
                    </td>       
                    <td>
                        <a href="#/hosts" data-i18n="Nodes">
                            <%= i18n.t('Nodes') %>
                        </a>
                    </td>
                    <td>
                        <span class="summary-data js-summary-nodes">3</span>
                    </td>
                </tr>
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
                        <span class="summary-data js-summary-dis">0</span>
                    </td>
                </tr>
            </table>
        </div>
    </div>
</div>
<div class="home-wrapper">
    <div class="home-row">
        <div class="home-cell">
            <div class="home-title" data-i18n>Activity log</div>
        </div>
    </div>
    
    <table class="log-table">
        <tr>
            <td>a</td>
            <td>a</td>
            <td>a</td>
        </tr>
        <tr>
            <td>b</td>
            <td>b</td>
            <td>b</td>
        </tr>
        <tr>
            <td>v</td>
            <td>v</td>
            <td>v</td>
        </tr>
        <tr>
            <td>d</td>
            <td>d</td>
            <td>d</td>
        </tr>
        <tr>
            <td>t</td>
            <td>t</td>
            <td>t</td>
        </tr>
    </table>
</div>