library("tidyverse")
library("ggplot2")
library("dplyr")

plot_genome_linkage <- function(file_path) {
  # List all parametric.tbl files
  parametric_list <- list.files(path=file_path, 
                              pattern="-parametric.tbl",
                              full.names=TRUE)

  # Read each of the listed files into data frame
  linkage_table <- NULL
  for (f in parametric_list) {
    print(f)
    dat <- read_tsv(f)
    linkage_table <- rbind(linkage_table, dat)
  }
  
  # Sort dataframe based on chromosome
  linkage_table <- linkage_table %>% arrange(CHR)

  # Create labels for facets
  chr_labels <- c("1", "2", "3", "4", "5", "6", "7", "8",
                  "9", "10", "11", "12", "13", "14", "15",
                  "16", "17", "18", "19", "20", "21", "22", 
                  "X")
  names(chr_labels) <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
                        17, 18, 19, 20, 21, 22, 999)
  
  LOD_cutoffs <- data.frame( CHR = unique(linkage_table$CHR),
                             hline = c(3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
                                       3, 3, 3, 3, 3, 3, 3, 3, 3, 2))
  
  # Generate whole genome linkage plot
  ggplot(data=linkage_table, aes(x=POS, y=LOD), group = CHR) + 
    geom_line() +
    facet_grid(. ~ CHR, 
               scales = 'free', 
               space = 'free', 
               switch = 'both',
               labeller = as_labeller(chr_labels)) +
    coord_cartesian(ylim= c (-2,4)) +
    scale_y_continuous(breaks = seq(-2, 4, 1)) +
    geom_hline(data = LOD_cutoffs, 
               aes(yintercept = hline, colour = "red"),
               show.legend = FALSE) +
    xlab("Chromosome") + 
    ylab("LOD Score") +
    theme(axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_blank(),
          panel.grid.major.y = element_line(colour = "grey95"),
          panel.spacing = unit(0, 'npc'),
          panel.border = element_rect(color = "white", fill = NA, size = 1),
          strip.background = element_rect(fill = "white", color = "white", size = 1))
}





plot_combined_genome_linkage <- function(...) {
  
  # Generate list of input paths
  path_list <- list(...)

  # Initialise list to store iterations of linkage data
  table_list <- NULL
  
  # Populate list with data.frame names, 1 per linkage iteration
  for (n in 1:length(path_list)){
    table_list[[n]] <- paste("linkage_table", n, sep = "_")
  }
  
  # Store linkage data within data.frames stored in list
  for (n in 1:length(path_list)){
    # Read contents of '-parametic.tbl' from supplied directories into data.frames
    parametric_table <- list.files(path=path_list[[n]], 
                        pattern="-parametric.tbl",
                        full.names=TRUE)
    
    # Store contents of "-parametric.tbl" in data.frames stored in above made list
    for (f in parametric_table) {
      dat <- read_tsv(f)
      print(dat)
      table_list[[n]] <- rbind(table_list[[n]], dat)
    }
  
    # Sort data.frame based on chromosome
    table_list[[n]] <- table_list[[n]] %>% arrange(CHR)
  }
  
  # Initialise data.frame with LOD scores for all iterations
  cumulative_LOD <- NULL
  
  # Store genomic position data and LOD scores from first linkage iteration
  cumulative_LOD <- rbind(cumulative_LOD, 
                          table_list[[1]][c("CHR","POS","LABEL","MODEL","LOD")])
  
  # Convert LOD from char to num to allow plotting
  cumulative_LOD$LOD <- as.numeric(as.character(cumulative_LOD$LOD))
  
  # Generate list to rename final cumulative_LOD data.frame to give LOD columns different names
  cumulative_names <- c("CHR","POS","LABEL","MODEL","LOD")
  for (n in 2:length(path_list)){
    cumulative_names[[4+n]] <- paste("LOD", n, sep = "_")
  }
  
  # Convert all remaining LOD scores to num and add to cumulative_LOD data.frame 
  for (n in 2:length(path_list)) {
    table_list[[n]]$LOD <- as.numeric(as.character(table_list[[n]]$LOD))
    cumulative_LOD <- cbind(cumulative_LOD, table_list[[n]]["LOD"])
  }
  
  # Rename columns using previously made list
  colnames(cumulative_LOD) <- cumulative_names
  
  # Somewhere in this code "linkage_table_1" gets included in data.frame, this removes it
  cumulative_LOD <- cumulative_LOD[!grepl("linkage",cumulative_LOD$CHR),]
  
  # Add all LOD columns together, place output in new "total" column
  cumulative_LOD <-cumulative_LOD %>% 
    mutate(Total = select(., -1:-4) %>% rowSums(na.rm = TRUE))

  # Convert CHR column to num, and sort 'cumulative_LOD' numerically (chromosome order)
  cumulative_LOD$CHR <- as.numeric(as.character(cumulative_LOD$CHR))
  cumulative_LOD <- cumulative_LOD %>% arrange(cumulative_LOD$CHR)

  # Converts chr labels from merlin to reader friendly titles
  chr_labels <- c("1", "2", "3", "4", "5", "6", "7", "8",
                  "9", "10", "11", "12", "13", "14", "15",
                  "16", "17", "18", "19", "20", "21", "22", 
                  "X")
  names(chr_labels) <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
                         17, 18, 19, 20, 21, 22, 999)
  
  # Add LOD cutoffs to indicate relevant values
  LOD_cutoffs <- data.frame( CHR = unique(cumulative_LOD$CHR),
                             hline = c(3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
                                       3, 3, 3, 3, 3, 3, 3, 3, 3, 2))

  # Generate whole genome linkage plot
  ggplot(cumulative_LOD, aes(x=POS, y=Total), group = CHR) +
    geom_line(aes(group = CHR)) +
    facet_grid(. ~ CHR,
               scales = 'free',
               space = 'free',
               switch = 'both',
               labeller = as_labeller(chr_labels)) +
    coord_cartesian(ylim= c (-2,12)) +
    scale_y_continuous(breaks = seq(-2, 12, 1)) +
    geom_hline(data = LOD_cutoffs,
               aes(yintercept = hline, colour = "red"),
               show.legend = FALSE) +
    xlab("Chromosome") +
    ylab("LOD Score") +
    theme(axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_blank(),
          panel.grid.major.y = element_line(colour = "grey95"),
          panel.spacing = unit(0, 'npc'),
          panel.border = element_rect(color = "white", fill = NA, size = 1),
          strip.background = element_rect(fill = "white", color = "white", size = 1))

}
