<%args>
$.board_applicants => sub { [] }
</%args>

% $.IndexTable {{
%   $.IndexHead {{
      <% $.IndexHeadName("Applicant") %>
      <% $.IndexHeadStatus("Status") %>
      <% $.IndexHeadActions("Modify") %>
%   }}
%   $.IndexBody {{
%     for my $applicant (@{$.board_applicants}) {
%       $.IndexItem {{
%         $.IndexItemName("", "") {{
            <% $applicant->user->name | H %>
%         }}
%         $.IndexItemStatus {{
            <!-- show the applicant status:
               - denied
               - accepted (application no longer visible except to some members)
               - vote-in-progress
               - preliminary (no voting yet)
               -->
            <% $applicant->status %>
%         }}
%         $.IndexItemActions {{
           <!-- % $.IndexItemAction(
                $layout->source_version->edition->is_closed,
                "", 
                "minus-sign", 
                "Discard Changes"
              ) % -->
%         }}
%       }}
%     }
%   }}
% }}
