Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$User = "username"
$Server = "ip adresse"
$Password = "password"
$ssh = "ssh $User@$Server"

wt -w 0 new-tab cmd /c $ssh
Start-Sleep -Seconds 2
[System.Windows.Forms.SendKeys]::SendWait("$Password{ENTER}")
Start-Sleep -Seconds 1


1..5 | ForEach-Object {
	
    	$Commande = "./Script/connection_peer.sh $_" # Ajoute le numéro de l'itération à la commande
    # Lance une commande Windows Terminal pour ouvrir un nouvel onglet avec une session SSH
    
   	 wt -w 0 new-tab cmd /c $ssh
    	Start-Sleep -Seconds 2  # Attend que la demande de mot de passe apparaisse

    # Utilise SendKeys pour envoyer le mot de passe (note : ceci peut ne pas fonctionner comme prévu)
    	[System.Windows.Forms.SendKeys]::SendWait("$Password{ENTER}")
    	Start-Sleep -Seconds 1  # Petite pause après l'envoi pour permettre à la session de s'établir
    	[System.Windows.Forms.SendKeys]::SendWait("$Commande{ENTER}")
	Start-Sleep -Seconds 1
}
