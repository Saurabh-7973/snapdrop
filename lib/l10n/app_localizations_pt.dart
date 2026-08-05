// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get app_share_dialog_text_1 =>
      'Compartilhe o Snapdrop com seus colegas';

  @override
  String get app_share_dialog_text_2 =>
      'Você compartilhou imagens com sucesso 3 vezes. Divulgue o Snapdrop para que seus colegas também possam se beneficiar!';

  @override
  String get app_share_dialog_share_now_button => 'Compartilhar agora';

  @override
  String get app_share_dialog_maybe_later_button => 'Talvez depois';

  @override
  String get app_share_text_1 =>
      '🚀 Descubra o Snapdrop - a maneira mais fácil de transferir imagens diretamente para seus designs no Figma! 🎨\n\n';

  @override
  String get app_share_text_2 =>
      '📲 Baixe agora e otimize seu fluxo de trabalho de design:\n\n';

  @override
  String get language_selection_herotext_1 => 'Selecione o seu';

  @override
  String get language_selection_herotext_2 => 'idioma preferido';

  @override
  String get language_selection_continue => 'Continuar';

  @override
  String get onboard_hero_text_1 => 'Compartilhe imagens';

  @override
  String get onboard_hero_text_2 => 'diretamente para o Figma';

  @override
  String get onboard_subline => 'Do telefone para o canvas, em segundos.';

  @override
  String get onboard_step_1 => 'Selecionar Imagens';

  @override
  String get onboard_step_2 => 'Escanear QR no Plugin do Figma';

  @override
  String get onboard_step_3 => 'Compartilhar';

  @override
  String get onboard_button_text => 'Começar';

  @override
  String get onboarding_title => 'Envie fotos direto para o Figma';

  @override
  String get onboarding_subtitle =>
      'O Snapdrop envia as imagens do seu telefone para a tela do Figma — através do plugin de desktop.';

  @override
  String get onboarding_step1_title =>
      'Abra o Snapdrop no Figma no seu computador';

  @override
  String get onboarding_step1_desc =>
      'O plugin de desktop mostra um código QR na sua tela.';

  @override
  String get onboarding_step2_title => 'Escolha suas fotos e escaneie esse QR';

  @override
  String get onboarding_step2_desc =>
      'Aponte seu telefone para o código para conectar.';

  @override
  String get onboarding_step3_title => 'Suas fotos chegam ao Figma';

  @override
  String get onboarding_step3_desc =>
      'Elas aparecem na sua tela, prontas para usar.';

  @override
  String get onboarding_note =>
      'O código QR vem do plugin de desktop do Figma — não deste app, nem do Figma mobile.';

  @override
  String get onboarding_cta => 'Começar';

  @override
  String get scan_subtitle => 'Aponte para o código do seu plugin do Figma';

  @override
  String get scan_help_link => 'Onde está o código QR?';

  @override
  String get qr_help_title => 'Onde está o código QR?';

  @override
  String get qr_help_step1 => 'Abra o Figma no seu computador desktop.';

  @override
  String get qr_help_step2 =>
      'Execute o plugin Snapdrop — Menu > Plugins, ou pesquise \"Snapdrop\".';

  @override
  String get qr_help_step3 =>
      'Um código QR aparece. Aponte seu telefone para ele.';

  @override
  String get qr_help_note =>
      'Precisa ser o Figma de desktop. O código é gerado pelo plugin, não por este app.';

  @override
  String get qr_help_dismiss => 'Entendi';

  @override
  String get showcase_one_title => 'Botão Dropdown';

  @override
  String get showcase_one_subtitle =>
      'Selecione álbuns de onde deseja escolher fotos';

  @override
  String get showcase_two_title => 'Selecionar Imagens';

  @override
  String get showcase_two_subtitle =>
      'Selecione imagens que deseja compartilhar';

  @override
  String get showcase_three_title => 'Botão de Conectar';

  @override
  String get showcase_three_subtitle => 'Avançar para o próximo passo';

  @override
  String get home_screen_herotext_1 => 'Selecionar Imagens';

  @override
  String get home_screen_herotext_2 => 'para Continuar';

  @override
  String get home_screen_herotext_3 => 'Até 10 Imagens';

  @override
  String get home_screen_button => 'Conectar';

  @override
  String get send_button => 'Enviar';

  @override
  String get connection_connected => 'Conectado';

  @override
  String get connection_not_connected => 'Sem conexão — escaneie para conectar';

  @override
  String get home_album_view_all => 'Ver tudo';

  @override
  String get empty_state_title => 'Ainda não há imagens aqui';

  @override
  String get empty_state_body =>
      'As fotos deste álbum aparecerão aqui. Tente outro álbum acima.';

  @override
  String get empty_state_none_title => 'Nenhuma foto encontrada';

  @override
  String get empty_state_none_body =>
      'Adicione fotos à sua galeria — ou permita o acesso às fotos — e atualize.';

  @override
  String get empty_state_refresh => 'Atualizar';

  @override
  String get album_search_hint => 'Buscar álbum';

  @override
  String get album_search_empty => 'Nenhum álbum com esse nome';

  @override
  String get language_sheet_title => 'Selecionar idioma';

  @override
  String get help_button => 'Ajuda';

  @override
  String size_limit_message(String limit, String size) {
    return 'Cada imagem deve ter menos de $limit MB (a maior tem $size MB).';
  }

  @override
  String get showcase_four_title => 'QR Scanner';

  @override
  String get showcase_four_subtitle => 'Clique para Escanear o Código QR';

  @override
  String get qr_screen_herotext_1 => 'Escanear Código QR';

  @override
  String get qr_screen_herotext_2 => 'para Continuar';

  @override
  String get qr_screen_herotext_3 => 'Escanear Código QR para Conectar';

  @override
  String get qr_timed_out_label => 'Tempo de leitura esgotado';

  @override
  String get qr_timed_out_message =>
      'Nenhum código QR lido — ele pode ter expirado.';

  @override
  String get qr_invalid_label => 'Esse código não funcionou';

  @override
  String get qr_invalid_message =>
      'Esse não é um código do Snapdrop. Escaneie o QR exibido pelo plugin do Figma no computador.';

  @override
  String get qr_restart_scan => 'Reiniciar leitura';

  @override
  String get no_internet_connection => 'Sem conexão com a internet';

  @override
  String get connection_lost => 'Conexão perdida';

  @override
  String get connection_lost_body =>
      'A sessão caiu. Reconecte para continuar enviando.';

  @override
  String get reconnect_button => 'Reconectar';

  @override
  String get qr_screen_info_button =>
      'Abrir Figma -> Arquivo de Design -> Plugin -> Snapdrop';

  @override
  String get qr_screen_button_scanning => 'Escaneando...';

  @override
  String get qr_screen_button_scanning_completed => 'Conectado com Sucesso';

  @override
  String get showcase_five_title => 'Botão Fechar';

  @override
  String get showcase_five_subtitle => 'Sair do Aplicativo';

  @override
  String get showcase_six_title => 'Botão Enviar';

  @override
  String get showcase_six_subtitle => 'Enviar Mais Imagens';

  @override
  String get send_screen_hero_text_1 => 'Imagens';

  @override
  String get send_screen_hero_text_2 => 'Transferidas';

  @override
  String get send_screen_transferring => 'Transferindo';

  @override
  String get send_screen_complete_1 => 'Transferência';

  @override
  String get send_screen_complete_2 => 'Concluída';

  @override
  String get send_screen_connected_to => 'CONECTADO A';

  @override
  String get send_screen_your_id => 'SEU ID';

  @override
  String get send_screen_connect_button => 'Clique para Enviar';

  @override
  String get send_screen_close_button => 'Fechar';

  @override
  String get send_screen_send_more_button => 'Enviar';

  @override
  String get app_conditions_internet_connection =>
      'Verifique sua conexão com a Internet e tente novamente!';

  @override
  String get app_conditions_image_selection_limit =>
      'Só é possível selecionar até 10 imagens!';

  @override
  String get app_conditions_size_limit =>
      'Limite de tamanho do arquivo excedido';

  @override
  String get permission_dialog_title => 'Permitir acesso às fotos';

  @override
  String get permission_dialog_body =>
      'O Snapdrop precisa das suas fotos para enviá-las ao Figma. Nada sai do seu telefone até você selecionar e enviar.';

  @override
  String get permission_dialog_allow => 'Permitir';

  @override
  String get permission_dialog_exit => 'Sair';

  @override
  String get exit_dialog_title => 'Sair do Snapdrop?';

  @override
  String get exit_dialog_body => 'Sua seleção atual não será salva.';

  @override
  String get exit_dialog_exit => 'Sair';

  @override
  String get exit_dialog_cancel => 'Cancelar';

  @override
  String get share_dialog_title => 'Gostando do Snapdrop?';

  @override
  String get share_dialog_body =>
      'Se ele economizou seu tempo, passá-lo a outro designer ajuda mais do que você imagina.';

  @override
  String get share_dialog_share => 'Compartilhar';

  @override
  String get share_dialog_maybe_later => 'Talvez depois';
}
