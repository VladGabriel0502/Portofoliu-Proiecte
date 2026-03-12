function Figuri_Comenzi_Iesiri( y1, y1_ref, y2, y2_ref, u1, u1_ref, u2, u2_ref, timp )
    % Cosmetizare grafice
    figure, fig_look(gcf,2,14,1) ;

    % Plot iesire 1
    hold on
    plot( timp, y1_ref, 'Color', 'Red' ) ;
    plot( timp, y1, 'Color','Blue' ) ;
    legend('Referinta', 'Iesire y1') ;
    title('Grafic Iesire y1') ;
    xlabel('Timp [s]') ;
    ylabel('Nivel de lichid [cm]') ;
    grid on
    hold off

    % Plot iesire 2
    figure, fig_look(gcf,2,14,1) ;
    hold on
    plot( timp, y2_ref, 'Color', 'Red' ) ;
    plot( timp, y2, 'Color','Blue' ) ;
    legend('Referinta', 'Iesire y2') ;
    title('Grafic Iesire y2') ;
    xlabel('Timp [s]') ;
    ylabel('Nivel de lichid [cm]') ;
    grid on
    hold off

    % Plot intrare 1
    figure, fig_look(gcf,2,14,1) ;
    hold on
    plot( timp, u1_ref, 'Color', 'Red' ) ;
    plot( timp, u1, 'Color','Blue' ) ;
    legend('Referinta', 'Intrare u1') ;
    title('Grafic Intrare u1') ;
    xlabel('Timp [s]') ;
    ylabel('Voltaj [V]') ;
    grid on
    hold off

    % Plot intrare 2
    figure, fig_look(gcf,2,14,1) ;
    hold on
    plot( timp, u2_ref, 'Color', 'Red' ) ;
    plot( timp, u2, 'Color','Blue' ) ;
    legend('Referinta', 'Intrare u2') ;
    title('Grafic Intrare u2') ;
    xlabel('Timp [s]') ;
    ylabel('Voltaj [V]') ;
    grid on
    hold off
end