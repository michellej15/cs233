module blackbox(j, y, u, b);
    output j;
    input  y, u, b;
    wire   w00, w01, w02, w03, w09, w14, w17, w20, w22, w23, w24, w39, w50, w58, w65, w70, w80, w97;
    or  o57(j, w00, w17, w80);
    and a43(w00, w20, w70, w09);
    not n71(w09, w50);
    and a68(w17, w70, w50, w20);
    and a67(w80, w58, w14);
    not n47(w58, w70);
    or  o79(w14, w23, w65);
    and a4(w23, w20, w50);
    and a89(w65, w24, w20);
    not n10(w24, w50);
    and a41(w70, y, w39);
    or  o59(w39, u, b);
    and a12(w50, w03, w01);
    not n98(w03, u);
    or  o62(w01, y, b);
    or  o60(w20, w97, w22, w02);
    not n28(w97, y);
    not n44(w22, b);
    not n93(w02, u);
endmodule // blackbox
